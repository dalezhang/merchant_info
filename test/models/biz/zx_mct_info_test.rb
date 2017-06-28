require 'test_helper'

class ZxMctInfoTest < ActiveSupport::TestCase
  test "initialize" do
	user = User.create(email: 'test@mail.com',partner_id: 'test')
	merchant = create(:merchant, user: user, partner_mch_id: '123')
	biz = Biz::ZxMctInfo.new(merchant)
	biz.prepare_request
	# puts JSON.pretty_generate merchant.inspect
	assert merchant.inspect
	assert_equal '0001',merchant.request_and_response.zx_request[:alipay][:pay_chnl_encd]
	assert_equal '0002',merchant.request_and_response.zx_request[:wechat][:pay_chnl_encd]
	assert_equal 1,merchant.request_and_response.zx_request[:wechat][:acct_typ]
  end
end
