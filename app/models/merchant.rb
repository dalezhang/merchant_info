class Merchant < ApplicationRecord
	attr_accessor :status, :mch_id, :chnl_id
  def self.attr_arr
    [
	    :bank_account, :lics, :chnl_id, :full_name, :name, :contact_tel,
		  :contact_name, :service_tel, :contact_email, :memo,
		  :province, :urbn, :address, :owner_name, :bank_name,
      :bank_sub_code, :account_num
    ]
  end
end
