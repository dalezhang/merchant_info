require 'test_helper'

class PfbMctInfoTest < ActiveSupport::TestCase
  test "prepare_request" do
  	clean_database
	user = User.create(email: 'test@mail.com', bucket_url: 'www.abc.com',partner_id: 'test')
	merchant = create(:merchant, user: user, merchant_id: '12312314', partner_mch_id: '1231254')

	biz = Biz::PfbMctInfo.new(merchant)
	def biz.upload_picture(key)
		true 
	end
	biz.prepare_request
	puts biz.inspect
	assert '12312314', biz.inspect['outMchId']
  end
end
