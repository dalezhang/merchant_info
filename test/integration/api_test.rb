require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  test "create merchant" do
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
    }
    jwt = Biz::Jwt.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal 'Merchant', data['_type'], body['_type']
  end
   test "update merchant" do
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
    }
    jwt = Biz::Jwt.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal 'Merchant', data['_type'], body['_type']
  end
end
