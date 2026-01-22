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

  def update
    @recipe = Recipe.find(params[:id])

    if @recipe.update(recipe_update_params)
      redirect_to @recipe, notice: "Recipe updated"
    else
      redirect_to @recipe, alert: "Failed to update recipe"
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @coffee_bean = @recipe.coffee_bean
    @recipe.destroy
    redirect_to @coffee_bean, notice: "Recipe deleted"
  end

  private

  def recipe_params
    params.require(:recipe).permit(:prompt, :recipe_type, :source_recipe_id)
  end

  def recipe_update_params
    params.require(:recipe).permit(:published)
  end
end
