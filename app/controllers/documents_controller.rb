class DocumentsController < ApplicationController
  def search
    query = params[:q].to_s
    results = Document.similar_to(query)
    render json: results.as_json(only: %i[id title body])
  end
end
