require 'test_helper'

class ZxMctInfoTest < ActiveSupport::TestCase
  test "real test" do
	user = User.create(email: 'test@mail.com')
	merchant = create(:merchant, user_id: user.id.to_s)
  	biz = Biz::CoreAccount.create_backend_account merchant
  	assert merchant.merchant_id
  end
end