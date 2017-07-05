require 'test_helper'

class ApiMd5Test < ActionDispatch::IntegrationTest
  test "create merchant" do
    clean_database
    user = User.new(email: 'test@mail.com',partner_id: 'test')
    user.save!
    # data = {
    #   token: user.token,
    #   method: 'merchant.create',
    #   partner_id: user.partner_id,
    #   partner_mch_id: 'c214',
    #   t1_rate: 1,
    #   d0_rate: 1,
    # }
    data = {
      partner_id: user.partner_id,
      "partner_mch_id": "15880245466",
      "method": "merchant.create",
      "full_name": "福建盟购信息有限公司",
      "name": "盟购",
      "memo": "商家",
      "province": "河北省",
      "urbn": "石家庄市",
      "zone": "市辖区",
      "address": "厦门市集美区后溪镇岩内村内湖打石山",
      "appid": "2017031406213191",
      "mch_type": "个体",
      "industry": "奢侈品",
      "pfb_channel_type": {
        'wechat': '微信经营类目编码',
        'alipay': '支付宝经营类目编码',
        },
      "mch_deal_type": "虚拟",
      "d0_rate": "0.38",
      "t1_rate": "0.35",
      "fixed_fee": "1",
      "bank_info": {
        "owner_name": "曾维鹏",
        "bank_sub_code": "305393000108",
        "account_num": "622622290058936",
        "account_type": "对私",
        "owner_idcard": "350426198709095599",
        "province": "河北省",
        "urbn": "石家庄市",
        "zone": "市辖区",
        "bank_full_name": "中国民生银行",
        "is_nt_citic": "否",
        "right_bank_card_key": "201503141113325305.jpg"
      },
      "legal_person": {
        "identity_card_front_key": "201503141113224299.jpg",
        "identity_card_back_key": "201503141113279563.jpg",
        "tel": "15880245466",
        "name": "曾维鹏",
        "email": "365609166@qq.com",
        "identity_card_num": "350426198709095599",
        "id_with_hand_key": "405892185375827708.jpg"
      },
      "company": {
        "contact_tel": "15880245466",
        "contact_name": "曾维鹏",
        "service_tel": "400-0369079",
        "contact_email": "365609166@qq.com"
      },
    }
    puts 'email', user.email
    puts "user.token", user.token
    data[:sign] = get_mac data, user.token

    post url_for(controller: 'api/merchants', action: :create), data
    assert_response :success
    data = JSON.parse response.body
    puts data
    assert_equal 1, data['status'], data
  end
  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
  def get_mab(js)
    mab = []
    js.keys.sort.each do |k|
      mab << "#{k}=#{js[k].to_s}" if ![:mac, :sign, :controller, :action ].include?(k.to_sym) && js[k] && js[k].class != Hash
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
