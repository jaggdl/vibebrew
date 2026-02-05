module ApplicationHelper
  def coffee_bean_link(coffee_bean)
    if coffee_bean.owned_by_current_user?
      coffee_bean_path(coffee_bean)
    else
      bean_path(coffee_bean.slug)
    end
  end

  def recipe_link(recipe)
    if recipe.owned_by_current_user?
      recipe_path(recipe)
    else
      brew_path(recipe.slug)
    end
  end
end
