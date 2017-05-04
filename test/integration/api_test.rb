require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  test "create merchant" do
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    jwt = Biz::Jwt.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal '初始', data['status'], data['status']
  end
   test "update merchant" do
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    jwt = Biz::Jwt.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    data = JSON.parse response.body
    id = data['id']
    update_data = {
      token: user.token,
      method: 'merchant.update',
      id: id,
      name: '123',
    }
    jwt = Biz::Jwt.hsh_encode update_data
    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    data = JSON.parse response.body
    puts data
    assert_equal '123', data['name'], data['name']
  end
end
