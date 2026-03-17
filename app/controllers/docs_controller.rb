class DocsController < ApplicationController
  def index
    @docs = Docs::Store.all.sort_by { |doc| [doc.category.to_s.downcase, doc.title.to_s.downcase] }
    @categories = @docs.group_by { |doc| doc.category.presence || "General" }
  end

  def show
    @doc = Docs::Store.find(params[:id])
    raise ActiveRecord::RecordNotFound, "Doc not found" unless @doc
  end
end
