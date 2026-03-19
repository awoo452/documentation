module Docs
  class Importer
    def self.import!(force: false)
      if Docs::Store.source == "database" && !force
        Rails.logger.info("Docs import skipped: DOCS_SOURCE=database.")
        return
      end

      unless ActiveRecord::Base.connection.data_source_exists?("documents")
        Rails.logger.warn("Docs import skipped: documents table missing. Run db:migrate.")
        return
      end

      Docs::Store.all.each do |entry|
        document = Document.find_or_initialize_by(title: entry.title)
        document.body = flatten_entry(entry)
        document.save!
      end
    end

    def self.flatten_entry(entry)
      parts = []
      parts << entry.summary if entry.summary.present?

      entry.sections.each do |section|
        heading = section["heading"].to_s
        parts << heading if heading.present?

        Array(section["body"]).each { |paragraph| parts << paragraph.to_s }
        Array(section["bullets"]).each { |bullet| parts << "- #{bullet}" }

        Array(section["steps"]).each_with_index do |step, index|
          parts << "#{index + 1}. #{step}"
        end

        code = section["code"].to_s
        parts << code if code.present?
      end

      parts.compact.join("\n")
    end
  end
end
