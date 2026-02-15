module CoffeeBean::VectorSearch
  extend ActiveSupport::Concern

  included do
    has_one :coffee_bean_vector, dependent: :destroy
  end

  def find_or_create_vector
    return if embedding_text.blank?

    CoffeeBeanVector.find_or_create_by!(coffee_bean: self) do |vector|
      vector.embedding = Embeddings.create(embedding_text).embedding
    end
  end

  def similar(limit: 8)
    return self.class.none unless coffee_bean_vector

    vectors = CoffeeBeanVector.similar_to(coffee_bean_vector.embedding, limit: limit + 1)
    coffee_bean_ids = vectors.map(&:coffee_bean_id) - [ id ]
    self.class.where(id: coffee_bean_ids)
  end

  def embedding_text
    parts = []
    parts << "Brand: #{brand}" if brand.present?
    parts << "Origin: #{origin}" if origin.present?
    parts << "Variety: #{display_variety}" if variety.any?
    parts << "Process: #{display_process}" if process.any?
    parts << "Producer: #{producer}" if producer.present?
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
  end
end
