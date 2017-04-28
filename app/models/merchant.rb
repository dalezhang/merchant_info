class Merchant < ApplicationRecord
	include Mongoid::Document
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
  # field :legal_person, type: Hash, default:{} # 法人信息
  # field :company, type: Hash, default:{} # 公司信息
  field :request_and_response, type: Hash, default:{} # 发送和返回
  field :channel_data, type: Hash, default:{} # 渠道信息
  belongs_to :user
  has_one :legal_person, autosave: true
  has_one :company, autosave: true

  STATUS_DATA = {0 => '初始', 1 => '进件失败', 6 => '审核中', 7 => '关闭', 8 => '进件成功'}

  def self.attr_arr
    [
		:bank_account, :lics, :chnl_id, :full_name, :name, :contact_tel,
		:contact_name, :service_tel, :contact_email, :memo,
		:province, :urbn, :address, :owner_name, :bank_name,
		:bank_sub_code, :account_num
    ]
  end
  def legal_person
    LegalPerson.find_or_initialize_by(merchant: self)
  end
  def Company
    Company.find_or_initialize_by(merchant: self)
  end
end

class LegalPerson < ApplicationRecord
  include Mongoid::Document
  include Imagable
  has_one :identity_card_front, class_name: 'AssetImg'    # 身份证正面
  has_one :identity_card_back , class_name: 'AssetImg'    # 身份证反面
  belongs_to :merchant
  field :tel, type: String               # 联系人电话
  field :name, type: String              # 联系人名称
  field :email, type: String             # 联系人邮箱
  field :identity_card_num, type: String # 身份证号
end

class Company < ApplicationRecord
  include Mongoid::Document
  include Imagable
  has_one :license, class_name: 'AssetImg' # 营业执照
  has_one :shop_picture, class_name: 'AssetImg' # 店铺门头照
  belongs_to :merchant
  field :contact_tel, type: String  # 联系人电话
  field :contact_name, type: String # 联系人姓名
  field :service_tel, type: String  # 客服电话
  field :contact_email, type: String# 联系人邮箱
  field :license_code, type: String # 营业执照编码
end

