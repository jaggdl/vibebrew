class CommentsController < ApplicationController
  before_action :set_commentable, only: [:create]
  before_action :authorize_owner!, only: [:create]
  before_action :set_comment, only: [:toggle_publish]
  before_action :authorize_comment_owner!, only: [:toggle_publish]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @commentable, notice: "Comment added successfully" }
      end
    else
      redirect_to @commentable, alert: "Failed to add comment"
    end
  end

  def toggle_publish
    @comment.toggle_publish

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@comment) }
      format.html { redirect_back fallback_location: polymorphic_path(@comment.commentable) }
    end
  end

  private

  def set_commentable
    @commentable = if params[:recipe_id]
                     Recipe.find(params[:recipe_id])
                   elsif params[:coffee_bean_id]
                     CoffeeBean.find(params[:coffee_bean_id])
                   else
                     raise ActionController::RoutingError, "Not found"
                   end
  end

  def authorize_owner!
    unless @commentable.owned_by_current_user?
      redirect_to @commentable, alert: "Only the owner can add comments"
    end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def authorize_comment_owner!
    unless @comment.owned_by_current_user?
      redirect_to @comment.commentable, alert: "Only the owner can publish/unpublish comments"
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
