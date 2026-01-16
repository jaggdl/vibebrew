class Recipes::V60Controller < ApplicationController
  def create
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
    @v60_recipe = @coffee_bean.v60_recipes.build(v60_recipe_params)

    if @v60_recipe.save
      GenerateRecipeJob.perform_later(@v60_recipe.class.name, @v60_recipe.id)
      redirect_to recipes_v60_path(@v60_recipe)
    else
      redirect_to @coffee_bean, alert: "Failed to create recipe"
    end
  end

  def show
    @v60_recipe = V60Recipe.find(params[:id])
    @coffee_bean = @v60_recipe.coffee_bean
  end

  private

  def v60_recipe_params
    params.require(:v60_recipe).permit(:prompt)
  end
end
