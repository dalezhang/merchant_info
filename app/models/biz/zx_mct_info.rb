class Biz::ZxMctInfo
	attr_names = [
		:bank_account, :lics :chnl_id, :full_name, :name, :contact_tel, 
		:contact_name, :service_tel, :contact_email, :memo, 
		:province, :urbn, :address
	]
	attr_accessor attr_names
	def initialize(merchant)
		@merchant = merchant
		@chnl_id = @merchant.chnl_id # 商户归属渠道编号
		@full_name = @merchant.full_name #商户全名称
		@name = @merchant.name # 商户简称
		@contact_tel = @merchant.contact_tel # 客户服务电话
		@contact_name = @merchant.contact_name # 联系人名称
		@service_tel = @merchant.service_tel # 联系人电话
		@contact_email = @merchant.contact_email # 联系人邮箱
		@memo = @merchant.memo # 商户备注
		@province = @merchant.province # 省份（字典
		@urbn = @merchant.urbn # 城市（汉字标示
		@address = @merchant.address # 详细地址
	end
end
