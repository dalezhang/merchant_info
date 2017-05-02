class Merchant < ApplicationRecord
  include Mongoid::Timestamps
  field :user_id
  field :merchant_id, type: String # 商户编号
  field :status, type: Integer, default: 0 # 状态
  field :full_name, type: String # 商户全名称
  field :name, type: String # 商户简称
  field :memo, type: String # 商户备注
  field :province, type: String # 省份
  field :urbn, type: String # 城市
  field :address, type: String # 详细地址
  field :appid, type: Integer # 公众号
  field :mch_type, type: String # 商户类型(个体，企业)
  field :industry, type: String # 经营行业

  field :bank_info, type: Hash, default:{} # 银行信息
  field :legal_person # 法人信息
  field :company # 公司信息
  field :request_and_response, type: Hash, default:{} # 发送和返回
  field :channel_data, type: Hash, default:{} # 渠道信息
  belongs_to :user
  embeds_one :legal_person, autobuild: true
  embeds_one :company, autobuild: true
  accepts_nested_attributes_for :company, :legal_person

  STATUS_DATA = {0 => '初始', 1 => '进件失败', 6 => '审核中', 7 => '关闭', 8 => '进件成功'}

  def self.attr_arr
    [
		:bank_account, :lics, :chnl_id, :full_name, :name, :contact_tel,
		:contact_name, :service_tel, :contact_email, :memo,
		:province, :urbn, :address, :owner_name, :bank_name,
		:bank_sub_code, :account_num
    ]
  end
end

class LegalPerson < ApplicationRecord
  include Imagable
  embedded_in :merchant
  field :identity_card_front_token, type: String    # 身份证正面
  field :identity_card_back_token, type: String    # 身份证反面  
  field :tel, type: String               # 联系人电话
  field :name, type: String              # 联系人名称
  field :email, type: String             # 联系人邮箱
  field :identity_card_num, type: String # 身份证号
  before_save :save_relate_asset_img
  def save_relate_asset_img
    @license.save
    @shop_picture.save
  end
end

class Company < ApplicationRecord
  include Imagable
  embedded_in :merchant
  field :shop_picture_token, type: String  # 店铺照
  field :license_token, type: String   # 营业执照
  field :contact_tel, type: String  # 联系人电话
  field :contact_name, type: String # 联系人姓名
  field :service_tel, type: String  # 客服电话
  field :contact_email, type: String# 联系人邮箱
  field :license_code, type: String # 营业执照编码
  before_save :save_relate_asset_img
  def license
    get_asset_img('license')
  end
  def shop_picture
    get_asset_img('shop_picture')
  end
  def save_relate_asset_img
    @license.save if @license
    @shop_picture.save if @shop_picture
  end
end

