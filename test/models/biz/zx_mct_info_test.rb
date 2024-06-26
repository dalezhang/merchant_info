require 'test_helper'

class ZxMctInfoTest < ActiveSupport::TestCase
  test "initialize" do
  	clean_database
	user = User.create(email: 'test@mail.com',partner_id: 'test')
	merchant = create(:merchant, user: user, partner_mch_id: '123')
	biz = Biz::ZxMctInfo.new(merchant)
	biz.prepare_request
	# puts JSON.pretty_generate merchant.inspect
	assert merchant.inspect
	assert_equal '0001',merchant.request_and_response.zx_request[:alipay][:pay_chnl_encd]
	assert_equal '0002',merchant.request_and_response.zx_request[:wechat][:pay_chnl_encd]
	assert_equal 4,merchant.request_and_response.zx_request[:wechat][:acct_typ]

	merchant.bank_info.bank_full_name = "  中信银行深圳分行  "
	merchant.bank_info.account_type = "对私"
	merchant.save
	biz = Biz::ZxMctInfo.new(merchant)
	biz.prepare_request
	assert_equal 1,merchant.request_and_response.zx_request[:wechat][:acct_typ]
	assert_equal "中信银行深圳分行",merchant.request_and_response.zx_request[:wechat][:opn_bnk]

	merchant.bank_info.account_type = "对公"
	merchant.save
	biz = Biz::ZxMctInfo.new(merchant)
	biz.prepare_request
	assert_equal 2,merchant.request_and_response.zx_request[:wechat][:acct_typ]
  end
end
