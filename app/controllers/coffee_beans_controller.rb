class CoffeeBeansController < ApplicationController
  def index
    @coffee_beans = CoffeeBean.all
  end

  def show
    @coffee_bean = CoffeeBean.find(params[:id])
  end

  def new
    @coffee_bean = CoffeeBean.new
  end

  def create
    @coffee_bean = CoffeeBean.new(coffee_bean_params)

    if @coffee_bean.save
      redirect_to @coffee_bean, notice: 'Coffee bean was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @coffee_bean = CoffeeBean.find(params[:id])
  end

  def update
    @coffee_bean = CoffeeBean.find(params[:id])

    if @coffee_bean.update(coffee_bean_update_params)
      redirect_to @coffee_bean, notice: 'Coffee bean was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def coffee_bean_params
    params.require(:coffee_bean).permit(images: [])
  end

  def coffee_bean_update_params
    params.require(:coffee_bean).permit(:brand, :origin, :variety, :process, :tasting_notes, :producer, :notes, images: [])
  end
end
