class Document < ApplicationRecord
  def embedding_input
    [title, body].compact.join("\n")
  end

  def generate_embedding!
    vector = EmbeddingService.embed(embedding_input)
    vector_literal = self.class.send(:vector_literal_for, vector)
    self.class.where(id: id).update_all(["embedding = ?::vector", vector_literal])
    reload
  end

  def self.similar_to(text, limit: 5)
    vector = EmbeddingService.embed(text.to_s)
    vector_literal = vector_literal_for(vector)

    order(Arel.sql("embedding <-> '#{vector_literal}'"))
      .limit(limit)
  end

  def self.vector_literal_for(vector)
    "[" + Array(vector).map { |value| Float(value) }.join(",") + "]"
  end
  private_class_method :vector_literal_for
end
