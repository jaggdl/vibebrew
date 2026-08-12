require "test_helper"

class CoffeeBeansControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email_address: "one@example.com", password: "password" }
  end

  test "should get index" do
    get coffee_beans_url
    assert_response :success
  end

  test "should get show" do
    get coffee_bean_url(coffee_beans(:one))
    assert_response :success
  end

  test "should get new" do
    get new_coffee_bean_url
    assert_response :success
  end

  test "should create coffee bean" do
    assert_difference("CoffeeBean.count") do
      post coffee_beans_url, params: { coffee_bean: { brand: "Test Blend", images: [ fixture_file_upload("bean-image.png", "image/png") ] } }
    end

    assert_redirected_to coffee_beans_url
  end
end
