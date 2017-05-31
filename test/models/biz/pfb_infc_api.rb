require 'test_helper'

class PfbInfcApiTest < ActiveSupport::TestCase
  test "prepare_request" do
  	user = User.create(email: 'test@mail.com', bucket_url: 'www.abc.com')
	merchant = create(:merchant, user: user, merchant_id: '12312314')
	biz = Biz::PfbMctInfo.new(merchant)
	def biz.upload_picture(key)
		true 
	end
	biz.prepare_request
	merchant.reload
	biz = Biz::PfbInfcApi.new(merchant, 'alipay')
	js = biz.prepare_request('ENTERPRISE')

	assert 'ENTERPRISE', js['serviceType']
  end
end
