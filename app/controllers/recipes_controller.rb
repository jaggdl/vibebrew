class RecipesController < ApplicationController
  def create
    @coffee_bean = CoffeeBean.find(params[:coffee_bean_id])
    @recipe = @coffee_bean.recipes.build(recipe_params)
    @recipe.team = @coffee_bean.team

    if @recipe.save
      @recipe.generate_later
      redirect_to @coffee_bean, notice: "Creating recipe..."
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

  def toggle_favorite
    @recipe = Recipe.find(params[:id])

    if Current.user.favorite_recipes_list.include?(@recipe)
      Current.user.favorite_recipes_list.delete(@recipe)
    else
      Current.user.favorite_recipes_list << @recipe
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("recipe_actions", partial: "recipes/actions", locals: { recipe: @recipe }) }
      format.html { redirect_back fallback_location: @recipe }
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:prompt, :recipe_type, :source_recipe_id)
  end

  def recipe_update_params
    params.require(:recipe).permit(:published)
  end
end
