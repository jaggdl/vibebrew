class V60RecipesController < ApplicationController
  before_action :set_coffee_bean

  def create
    @v60_recipe = @coffee_bean.v60_recipes.build(v60_recipe_params)

    if @v60_recipe.save
      GenerateRecipeJob.perform_later(@v60_recipe.class.name, @v60_recipe.id)
      redirect_to coffee_bean_v60_recipe_path(@coffee_bean, @v60_recipe)
    else
      redirect_to @coffee_bean, alert: "Failed to create recipe"
    end
  end

  def show
    @v60_recipe = @coffee_bean.v60_recipes.find(params[:id])
  end

  private

  def set_coffee_bean
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
  end

  def v60_recipe_params
    params.require(:v60_recipe).permit(:prompt)
  end
end
