class CoffeeBeanVector < ApplicationRecord
  belongs_to :coffee_bean

  validates :embedding, presence: true

  def self.similar_to(vector, limit: 10)
    return none if vector.blank?

    all.sort_by { |v| -v.cosine_similarity_to(vector) }.first(limit)
  end

  def cosine_similarity_to(other_vector)
    return 0 if embedding.blank? || other_vector.blank?

    dot_product = embedding.zip(other_vector).sum { |a, b| a.to_f * b.to_f }
    magnitude_product = Math.sqrt(embedding.sum { |x| x.to_f**2 }) *
                       Math.sqrt(other_vector.sum { |x| x.to_f**2 })

    magnitude_product.zero? ? 0 : dot_product / magnitude_product
  end
end
