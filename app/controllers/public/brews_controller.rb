module Public
  class BrewsController < BaseController
    def show
      @recipe = Recipe.find_by!(slug: params[:slug])
      require_published(@recipe)
    end
  end
end
