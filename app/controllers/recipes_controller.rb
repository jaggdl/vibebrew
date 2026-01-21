class RecipesController < ApplicationController
  def create
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
    @recipe = @coffee_bean.recipes.build(recipe_params)

    if @recipe.save
      GenerateRecipeJob.perform_later(@recipe.id)
      redirect_to recipe_path(@recipe)
    else
      redirect_to @coffee_bean, alert: "Failed to create recipe"
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @coffee_bean = @recipe.coffee_bean
  end

  private

  def recipe_params
    params.require(:recipe).permit(:prompt, :recipe_type, :source_recipe_id)
  end
end
