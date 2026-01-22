module Public
  class BeansController < BaseController
    def index
      @coffee_beans = CoffeeBean.published
    end

    def show
      @coffee_bean = CoffeeBean.find_by!(slug: params[:slug])
      require_published(@coffee_bean)
    end
  end
end
