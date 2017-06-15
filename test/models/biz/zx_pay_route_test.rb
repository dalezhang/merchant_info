require 'test_helper'

class ZxPayRouteTest < ActiveSupport::TestCase
  test "real test" do
    clean_database
    user = User.create(email: 'test@mail.com')
    merchant = create(:merchant, user: user, out_mch_id: '123')

    biz = Biz::PayRoute::BjrcbPayRoute.new merchant
    biz.send_wechat_offline
    assert merchant.merchant_id
  end
  def clean_database
    User.destroy_all
    Merchant.destroy_all
  end
end
