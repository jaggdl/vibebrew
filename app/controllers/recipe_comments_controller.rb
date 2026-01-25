class RecipeCommentsController < ApplicationController
  def create
    @recipe = Recipe.find(params[:recipe_id])
    @comment = @recipe.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @recipe, notice: "Comment added successfully" }
      end
    else
      redirect_to @recipe, alert: "Failed to add comment"
    end
  end

  def toggle_publish
    @comment = RecipeComment.find(params[:id])

    @comment.toggle_publish

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@comment) }
      format.html { redirect_back fallback_location: recipe_path(@comment.recipe) }
    end
  end

  private

  def comment_params
    params.require(:recipe_comment).permit(:body)
  end
end
