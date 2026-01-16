class AeropressRecipesController < ApplicationController
  before_action :set_coffee_bean

  def create
    @aeropress_recipe = @coffee_bean.aeropress_recipes.build(aeropress_recipe_params)

    if @aeropress_recipe.save
      GenerateRecipeJob.perform_later(@aeropress_recipe.class.name, @aeropress_recipe.id)
      redirect_to coffee_bean_aeropress_recipe_path(@coffee_bean, @aeropress_recipe)
    else
      redirect_to @coffee_bean, alert: 'Failed to create recipe'
    end
  end

  def show
    @aeropress_recipe = @coffee_bean.aeropress_recipes.find(params[:id])
  end

  private

  def set_coffee_bean
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
  end

  def aeropress_recipe_params
    params.require(:aeropress_recipe).permit(:prompt)
  end
end