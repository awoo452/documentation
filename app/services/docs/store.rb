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
      if source == "database"
        load_records.map { |record| build_entry_from_record(record) }
      else
        load_json.map { |item| build_entry(item) }
      end
    end

    def self.find(id)
      if source == "database"
        record = find_record(id)
        record ? build_entry_from_record(record) : nil
      else
        all.find { |entry| entry.id == id }
      end
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

    def self.build_entry_from_record(record)
      data = record.attributes.transform_keys(&:to_s)
      sections = extract_sections(record, data)
      tags = extract_array(data, record, "tags")
      audience = extract_array(data, record, "audience")
      links = extract_array(data, record, "links")

      Entry.new(
        id: record_identifier(record, data),
        title: data.fetch("title", "").to_s,
        summary: data.fetch("summary", "").to_s,
        category: data.fetch("category", "").to_s,
        tags: tags,
        audience: audience,
        status: data.fetch("status", "").to_s,
        updated_at: record_updated_at(record),
        sections: sections,
        links: links
      )
    end

    def self.source
      configured = ENV["DOCS_SOURCE"].presence || Rails.application.config.x.docs_source
      value = configured.to_s.downcase
      return "database" if %w[database db].include?(value)

      "json"
    end

    def self.load_json
      path = docs_path
      return [] unless File.exist?(path)

      JSON.parse(File.read(path))
    rescue JSON::ParserError => e
      Rails.logger.error("Docs JSON parse error: #{e.message}")
      []
    end

    def self.load_records
      return [] unless ActiveRecord::Base.connection.data_source_exists?("documents")

      Document.order(updated_at: :desc)
    end

    def self.find_record(id)
      return unless ActiveRecord::Base.connection.data_source_exists?("documents")

      if Document.column_names.include?("slug")
        Document.find_by(slug: id.to_s)
      else
        Document.find_by(id: id.to_s)
      end
    end

    def self.docs_path
      Rails.root.join("docs", "docs.json")
    end

    def self.record_identifier(record, data)
      if record.respond_to?(:slug) && record.slug.present?
        record.slug.to_s
      else
        data.fetch("id", record.id).to_s
      end
    end

    def self.record_updated_at(record)
      return "" unless record.respond_to?(:updated_at) && record.updated_at.present?

      record.updated_at.to_date.strftime("%Y-%m-%d")
    end

    def self.extract_array(data, record, key)
      value = data[key]
      if value.is_a?(String)
        begin
          parsed = JSON.parse(value)
          return Array(parsed).compact
        rescue JSON::ParserError
          return []
        end
      end

      return Array(value).compact if value.present?
      return [] unless record.respond_to?(key)

      Array(record.public_send(key)).compact
    end

    def self.extract_sections(record, data)
      value = data["sections"]
      if value.is_a?(String)
        begin
          parsed = JSON.parse(value)
          return Array(parsed)
        rescue JSON::ParserError
          value = nil
        end
      end

      return Array(value) if value.present?
      return [] unless record.respond_to?(:body)

      body = record.body.to_s
      paragraphs = body.split(/\n{2,}/).map(&:strip).reject(&:empty?)

      section = {}
      section["body"] = paragraphs if paragraphs.any?

      if record.respond_to?(:images)
        images_value = record.public_send(:images)
        images = case images_value
        when String
          begin
            JSON.parse(images_value)
          rescue JSON::ParserError
            []
          end
        when Array
          images_value
        else
          []
        end

        section["images"] = images if images.any?
      end

      section.empty? ? [] : [ section ]
    end
  end
end
