class CreateMerchants < ActiveRecord::Migration[5.0]
  def change
    create_table :merchants do |t|
	    t.string  "full_name"
	    t.string  "short_name"
	    t.string  "service_tel"
	    t.string  "business_category"
	    t.text    "memo"
	    t.string  "lic_number"
	    t.string  "jp_name"
	    t.string  "jp_id_number"
	    t.string  "contact_name"
	    t.string  "contact_tel"
	    t.string  "contact_email"
	    t.string  "province"
	    t.string  "urbn"
	    t.string  "city_area"
	    t.text    "address"
	    t.string  "channel_code"
	    t.string  "app_id"
	    t.string  "merchant_type"
	    t.string  "contact_mobile"
	    t.integer :status, default: 0
	    t.string :mch_id
	    t.string :chnl_id
		t.string :bank_account
		t.string :lics
		t.string :name
		t.string :owner_name
		t.string :bank_name
		t.string :bank_sub_code
		t.string :account_num
		t.integer :user_id
    end
  end
end
