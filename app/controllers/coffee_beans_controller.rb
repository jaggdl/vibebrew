class CoffeeBeansController < ApplicationController
  def index
    @coffee_beans = Current.user.coffee_beans
  end

  def show
    @coffee_bean = Current.user.coffee_beans.find(params[:id])
  end

  def new
    @coffee_bean = Current.user.coffee_beans.new
  end

  def create
    @coffee_bean = Current.user.coffee_beans.new(coffee_bean_params)

    if @coffee_bean.save
      ExtractCoffeeBeanInfoJob.perform_later(@coffee_bean.id)
      redirect_to @coffee_bean, notice: "Coffee bean was successfully created."
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

  private

  def coffee_bean_params
    params.require(:coffee_bean).permit(images: [])
  end

  def coffee_bean_update_params
    params.require(:coffee_bean).permit(:brand, :origin, :variety, :process, :tasting_notes, :producer, :notes, :published, images: [])
  end
end
