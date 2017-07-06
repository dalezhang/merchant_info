require 'test_helper'

class ApiJwtTest < ActionDispatch::IntegrationTest
  test "no email" do
    clean_database
    user = User.create(email: 'test@mail.com',partner_id: 'test')
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
    assert_equal 'partner_id为空', data['error'], data['error']
  end
  test "create merchant" do
    clean_database
    user = User.new(email: 'test@mail.com',partner_id: 'test')
    user.save!
    data = {
      token: user.token,
      method: 'merchant.create',
      partner_id: user.partner_id,
      partner_mch_id: 'c214',
      d0_rate: 1,
      t1_rate: 1,
    }
    puts 'email', user.email
    puts "user.token", user.token
    bz = Biz::Jwt.new(user.partner_id)
    jwt = bz.hsh_encode data

    post url_for(controller: 'api/merchants', action: :create), params: {jwt: jwt, partner_id: user.partner_id,}, as: :json
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal 1, data['status'], data
    assert_equal '入驻申请', data['status_desc'], data
  end
  test "update merchant" do
    clean_database
    user = User.create(email: 'test@mail.com',partner_id: 'test')
    data = {
      token: user.token,
      method: 'merchant.create',
      partner_id: user.partner_id,
      partner_mch_id: 'c1213',
      d0_rate: 1,
      t1_rate: 1,
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


end
