class Recipes::AeropressController < ApplicationController
  def create
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
    @aeropress_recipe = @coffee_bean.aeropress_recipes.build(aeropress_recipe_params)

    if @aeropress_recipe.save
      GenerateRecipeJob.perform_later(@aeropress_recipe.class.name, @aeropress_recipe.id)
      redirect_to recipes_aeropress_path(@aeropress_recipe)
    else
      redirect_to @coffee_bean, alert: "Failed to create recipe"
    end
  end

  def show
    @aeropress_recipe = AeropressRecipe.find(params[:id])
    @coffee_bean = @aeropress_recipe.coffee_bean
  end

  private

  def aeropress_recipe_params
    params.require(:aeropress_recipe).permit(:prompt)
  end
end
