require "test_helper"

class CoffeeBeansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coffee_beans_index_url
    assert_response :success
  end

  test "should get show" do
    get coffee_beans_show_url
    assert_response :success
  end

  test "should get new" do
    get coffee_beans_new_url
    assert_response :success
  end

  test "should get create" do
    get coffee_beans_create_url
    assert_response :success
  end
end
