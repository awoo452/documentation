require "net/http"
require "json"

class EmbeddingService
  def self.embed(text)
    uri = URI("https://api.openai.com/v1/embeddings")

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{ENV["OPENAI_API_KEY"]}"
    req["Content-Type"] = "application/json"

    req.body = {
      input: text,
      model: "text-embedding-3-small"
    }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    data = JSON.parse(res.body)
    embedding = data.dig("data", 0, "embedding")

    unless embedding
      message = data.dig("error", "message") || res.body
      raise "OpenAI embeddings error: #{message}"
    end

    embedding
  end
end
