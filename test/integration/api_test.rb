require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  test "no email" do
    clean_database
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    puts 'email', user.email
    bz = Biz::Jwt.new(user.email)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal 'email 不得为空', data['error'], data['error']
  end
   test "create merchant" do
    clean_database
    user = User.new(email: 'test@mail.com')
    user.save!
    
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    puts 'email', user.email
    puts "user.token", user.token
    bz = Biz::Jwt.new(user.email)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, email: user.email}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal '初始', data['status'], data['status']
  end
   test "update merchant" do
    clean_database
  	user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    puts 'email', user.email
    bz = Biz::Jwt.new(user.email)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    data = JSON.parse response.body
    id = data['id']
    update_data = {
      token: user.token,
      method: 'merchant.update',
      id: id,
      name: '123',
    }
    jwt = bz.hsh_encode update_data
    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, email: user.email}, as: :json
    data = JSON.parse response.body
    puts data
    assert_equal '123', data['name'], data['name']
  end
  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
end
