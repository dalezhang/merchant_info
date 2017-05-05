require 'test_helper'

class ZxMctInfoTest < ActiveSupport::TestCase
  test "initialize" do
	user = User.create(email: 'test@mail.com')
	merchant = create(:merchant, user_id: user.id.to_s)
	biz = Biz::ZxMctInfo.new(merchant)
	biz.prepare_request
	puts JSON.pretty_generate merchant.inspect
	assert merchant.inspect
	assert_equal '0001',merchant.request_and_response.zx_request[:alipay][:pay_chnl_encd]
	assert_equal '0002',merchant.request_and_response.zx_request[:wechat][:pay_chnl_encd]
	assert_equal 1,merchant.request_and_response.zx_request[:wechat][:acct_typ]
  end
end
