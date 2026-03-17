require "json"

module Docs
  class Store
    Entry = Struct.new(
      :id,
      :title,
      :summary,
      :category,
      :tags,
      :audience,
      :status,
      :updated_at,
      :sections,
      :links,
      keyword_init: true
    )

    def self.all
      load_json.map { |item| build_entry(item) }
    end

    def self.find(id)
      all.find { |entry| entry.id == id }
    end

    def self.build_entry(item)
      data = item.transform_keys(&:to_s)

      Entry.new(
        id: data.fetch("id", "").to_s,
        title: data.fetch("title", "").to_s,
        summary: data.fetch("summary", "").to_s,
        category: data.fetch("category", "").to_s,
        tags: Array(data["tags"]).compact,
        audience: Array(data["audience"]).compact,
        status: data.fetch("status", "draft").to_s,
        updated_at: data.fetch("updated_at", "").to_s,
        sections: Array(data["sections"]),
        links: Array(data["links"])
      )
    end

    def self.load_json
      path = docs_path
      return [] unless File.exist?(path)

      JSON.parse(File.read(path))
    rescue JSON::ParserError => e
      Rails.logger.error("Docs JSON parse error: #{e.message}")
      []
    end

    def self.docs_path
      Rails.root.join("docs", "docs.json")
    end
  end
end
