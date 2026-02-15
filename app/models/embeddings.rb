class Embeddings
  attr_reader :embedding

  def initialize(embedding)
    @embedding = embedding
  end

  def self.create(input)
    embedding = RubyLLM.embed(input)
    new(embedding.vectors)
  end

  def to_s = embedding.to_s
end
