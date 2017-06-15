require 'test_helper'

class ZxPayRouteTest < ActiveSupport::TestCase
  test "real test" do
    clean_database
    user = User.create(email: 'test@mail.com')
    merchant = create(:merchant, user: user, partner_mch_id: '123')
    biz = Biz::PayRoute::BjrcbPayRoute.new merchant
    biz.send_wechat_offline
    puts  merchant.request_and_response[:pfb_request]
    puts  merchant.request_and_response[:pfb_response]
    binding.pry
    #puts merchant.request_and_response[:pfb_request][:bjrbc_pay_route][:wechat_offline]
    #puts merchant.request_and_response[:pfb_response][:bjrbc_pay_route][:wechat_offline]
  end
  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
end
