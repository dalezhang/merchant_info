class Biz::ZxMctInfo
	attr_accessor :bank_account, :lics, :chnl_id, :full_name, :name, :contact_tel, 
		:contact_name, :service_tel, :contact_email, :memo, 
		:province, :urbn, :address, :owner_name, :bank_name,
    	:bank_sub_code, :account_num
	def initialize(merchant)
		@merchant = merchant
		@chnl_id = @merchant.chnl_id # 商户归属渠道编号
		@full_name = @merchant.full_name #商户全名称
		@name = @merchant.name # 商户简称
		@contact_tel = @merchant.contact_tel # 联系人电话
		@contact_name = @merchant.contact_name # 联系人名称
		@service_tel = @merchant.service_tel # 客服电话
		@contact_email = @merchant.contact_email # 联系人邮箱
		@memo = @merchant.memo # 商户备注
		@province = @merchant.province # 省份（字典
		@urbn = @merchant.urbn # 城市（汉字标示
		@address = @merchant.address # 详细地址
	    @owner_name = @merchant.owner_name # 账户名称（账号名）
	    @bank_name = @merchant.bank_name  # 开户行（中文名）
	    @bank_sub_code = @merchant.bank_sub_code # 支付联行号
	    @account_num = @merchant.account_num # 账号
	end
end
