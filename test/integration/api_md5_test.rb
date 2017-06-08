require 'test_helper'

class ApiMd5Test < ActionDispatch::IntegrationTest
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
    data[:sign] = get_mac data, user.token

    post url_for(controller: 'api/merchants', action: :create), data
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal '初始', data['status'], data
  end
  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
  def get_mab(js)
    mab = []
    js.keys.sort.each do |k|
      mab << "#{k}=#{js[k].to_s}" if k.to_sym != :mac && k.to_sym != :sign && js[k]
    end
    mab.join('&')
  end
  def md5(str)
    Digest::MD5.hexdigest(str)
  end
  def get_mac(js, key)
    md5(get_mab(js) + "&key=#{key}").upcase
  end
end
