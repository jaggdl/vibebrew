module CoffeeBean::VectorSearch
  extend ActiveSupport::Concern

  included do
    has_one :coffee_bean_vector, dependent: :destroy
    after_save :find_or_create_vector, if: :generated?
  end

  def find_or_create_vector
    return if embedding_text.blank?

    vector = coffee_bean_vector || build_coffee_bean_vector
    vector.embedding = Embeddings.create(embedding_text).embedding
    vector.save!
  end

  def similar(limit: 8)
    return self.class.none unless coffee_bean_vector

    vectors = CoffeeBeanVector.similar_to(coffee_bean_vector.embedding, limit: limit + 1)
    self.class.where(id: vectors.map(&:coffee_bean_id) - [ id ], user: user)
  end

  def embedding_text
    parts = []
    # Repeat brand 3x to give it more weight in the embedding
    3.times { parts << "Brand: #{brand}" } if brand.present?
    parts << "Origin: #{origin}" if origin.present?
    parts << "Variety: #{display_variety}" if variety.any?
    parts << "Process: #{display_process}" if process.any?
    # Repeat producer 2x for extra weight
    2.times { parts << "Producer: #{producer}" } if producer.present?
    parts << "Tasting Notes: #{tasting_notes.join(', ')}" if tasting_notes.any?
    parts << "Notes: #{notes}" if notes.present?
    parts.join(". ")
  end

  class_methods do
    def vector_search(embedding:, limit: 10)
      return none if embedding.blank?

      # Get coffee bean IDs from current scope (e.g., user's coffee beans)
      coffee_bean_ids = pluck(:id)
      return none if coffee_bean_ids.empty?

      # Find similar vectors but only for coffee beans in scope
      vectors = CoffeeBeanVector.where(coffee_bean_id: coffee_bean_ids).similar_to(embedding, limit: limit)
      where(id: vectors.map(&:coffee_bean_id))
    end

    # Hybrid search combining vector similarity with keyword matching
    # Weights: brand=3, origin=2, producer=2, variety=1, process=1, notes=1
    def hybrid_search(query:, embedding:, limit: 10)
      return none if query.blank? || embedding.blank?

      query_lower = query.downcase
      coffee_bean_ids = pluck(:id)
      return none if coffee_bean_ids.empty?

      # Get vector similarities
      vectors = CoffeeBeanVector.where(coffee_bean_id: coffee_bean_ids)
      scored_results = vectors.map do |vector|
        coffee_bean = vector.coffee_bean
        vector_score = vector.cosine_similarity_to(embedding)

        # Calculate keyword match score with weights
        keyword_score = 0.0
        keyword_score += 3.0 if coffee_bean.brand&.downcase&.include?(query_lower)
        keyword_score += 2.0 if coffee_bean.origin&.downcase&.include?(query_lower)
        keyword_score += 2.0 if coffee_bean.producer&.downcase&.include?(query_lower)
        keyword_score += 1.0 if coffee_bean.variety.any? { |v| v.downcase.include?(query_lower) }
        keyword_score += 1.0 if coffee_bean.process.any? { |p| p.downcase.include?(query_lower) }
        keyword_score += 1.0 if coffee_bean.notes&.downcase&.include?(query_lower)
        keyword_score += 1.0 if coffee_bean.tasting_notes.any? { |t| t.downcase.include?(query_lower) }

        # Normalize keyword score to 0-1 range (max possible is 11)
        normalized_keyword_score = [ keyword_score / 11.0, 1.0 ].min

        # Combined score: 70% vector, 30% keyword
        combined_score = (vector_score * 0.7) + (normalized_keyword_score * 0.3)

        [ coffee_bean, combined_score ]
      end

      # Sort by combined score and return top results
      scored_results.sort_by { |_, score| -score }.first(limit).map(&:first)
    end
  end
end
