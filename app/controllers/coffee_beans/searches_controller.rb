class CoffeeBeans::SearchesController < ApplicationController
  def show
    @query = params[:q].to_s.strip

    if @query.present?
      embedding = Embeddings.create(@query)
      @coffee_beans = Current.user.coffee_beans.vector_search(embedding: embedding.embedding, limit: 10)
    else
      @coffee_beans = []
    end
  end
end
