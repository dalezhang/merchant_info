require 'test_helper'

class ApiJwtTest < ActionDispatch::IntegrationTest
  test "no email" do
    clean_database
    user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create'
    }
    puts 'partner_id', user.partner_id
    bz = Biz::Jwt.new(user.partner_id)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal '找不到代理商信息，partner_id无效。', data['error'], data['error']
  end
  test "create merchant" do
    clean_database
    user = User.new(email: 'test@mail.com')
    user.save!
    data = {
      token: user.token,
      method: 'merchant.create',
      partner_id: user.partner_id,
      out_merchant_id: 'c214',
    }
    puts 'email', user.email
    puts "user.token", user.token
    bz = Biz::Jwt.new(user.partner_id)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, partner_id: user.partner_id,}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal '初始', data['status'], data
  end
  test "update merchant" do
    clean_database
    user = User.create(email: 'test@mail.com')
    data = {
      token: user.token,
      method: 'merchant.create',
      partner_id: user.partner_id,
      out_merchant_id: 'c1213',
    }
    puts 'email', user.email
    bz = Biz::Jwt.new(user.partner_id)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, partner_id: user.partner_id,}, as: :json
    data = JSON.parse response.body
    id = data['id']
    update_data = {
      token: user.token,
      method: 'merchant.update',
      id: id,
      name: '123',
    }
    jwt = bz.hsh_encode update_data
    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, partner_id: user.partner_id,}, as: :json
    data = JSON.parse response.body
    puts data
    assert_equal '123', data['name'], data
  end

  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
end
