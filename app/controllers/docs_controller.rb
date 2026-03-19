class DocsController < ApplicationController
  def index
    @query = params[:q].to_s
    @docs = Docs::Store.all
    @docs = filter_docs(@docs, @query) if @query.present?
    @docs = @docs.sort_by { |doc| [ doc.category.to_s.downcase, doc.title.to_s.downcase ] }
    @categories = @docs.group_by { |doc| doc.category.presence || "General" }
  end

  def show
    @doc = Docs::Store.find(params[:id])
    raise ActiveRecord::RecordNotFound, "Doc not found" unless @doc
  end

  private

  def filter_docs(docs, query)
    needle = query.downcase

    docs.select do |doc|
      parts = []
      parts << doc.title
      parts << doc.summary
      parts << doc.category
      parts << doc.status
      parts << doc.updated_at
      parts.concat(Array(doc.tags))
      parts.concat(Array(doc.audience))

      Array(doc.sections).each do |section|
        parts << section["heading"]
        parts.concat(Array(section["body"]))
        parts.concat(Array(section["bullets"]))
        parts.concat(Array(section["steps"]))
        parts << section["code"]
      end

      parts.compact.join(" ").downcase.include?(needle)
    end
  end
end
