class CoffeeBeansController < ApplicationController
  def index
    @rotations = Current.user.rotations.order(created_at: :desc)
    @favorites = Current.user.favorites.where.not(id: @rotations.select(:id)).order(created_at: :desc)
    @others = Current.user.coffee_beans.where.not(id: @rotations.select(:id)).where.not(id: @favorites.select(:id))
  end

  def show
    @coffee_bean = Current.user.coffee_beans.find(params[:id])
  end

  def new
    @coffee_bean = Current.user.coffee_beans.new
  end

  def create
    @coffee_bean = Current.user.coffee_beans.new(coffee_bean_params)
    @coffee_bean.team = Current.team

    if @coffee_bean.save
      ExtractCoffeeBeanInfoJob.perform_later(@coffee_bean.id)
      redirect_to coffee_beans_path, notice: "Coffee bean was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @coffee_bean = Current.user.coffee_beans.find(params[:id])
  end

  def update
    @coffee_bean = Current.user.coffee_beans.find(params[:id])

    if @coffee_bean.update(coffee_bean_update_params)
      redirect_to @coffee_bean, notice: "Coffee bean was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coffee_bean = Current.user.coffee_beans.find(params[:id])
    @coffee_bean.destroy
    redirect_to coffee_beans_path, notice: "Coffee bean was successfully deleted."
  end

  def toggle_favorite
    @coffee_bean = Current.user.coffee_beans.find(params[:id])

    if Current.user.favorites.include?(@coffee_bean)
      Current.user.favorites.delete(@coffee_bean)
    else
      Current.user.favorites << @coffee_bean
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("coffee_bean_actions", partial: "coffee_beans/actions", locals: { coffee_bean: @coffee_bean }) }
      format.html { redirect_back fallback_location: @coffee_bean }
    end
  end

  def toggle_rotation
    @coffee_bean = Current.user.coffee_beans.find(params[:id])

    if Current.user.rotations.include?(@coffee_bean)
      Current.user.rotations.delete(@coffee_bean)
    else
      Current.user.rotations << @coffee_bean
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("coffee_bean_actions", partial: "coffee_beans/actions", locals: { coffee_bean: @coffee_bean }) }
      format.html { redirect_back fallback_location: @coffee_bean }
    end
  end

  private

  def coffee_bean_params
    params.require(:coffee_bean).permit(images: [])
  end

  def coffee_bean_update_params
    params.require(:coffee_bean).permit(:brand, :origin, :variety, :process, :tasting_notes, :producer, :notes, :published, images: [])
  end
end
