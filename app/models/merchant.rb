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
  field :appid, type: String # 公众号
  field :mch_type, type: String # 商户类型(个体，企业)
  field :industry, type: String # 经营行业
  field :zx_channel_type, type: String # 中信经营类目，见附件《经营类目》中的经营类目明细编码

  field :bank_info, type: Hash, default:{} # 银行信息
  field :legal_person # 法人信息
  field :company # 公司信息
  field :request_and_response, type: Hash, default:{} # 发送和返回
  field :channel_data, type: Hash, default:{} # 渠道信息
  belongs_to :user
  embeds_one :legal_person, autobuild: true
  embeds_one :company, autobuild: true
  embeds_one :bank_info, autobuild: true
  accepts_nested_attributes_for :company, :legal_person, :bank_info
  embeds_one :request_and_response

  STATUS_DATA = {0 => '初始', 1 => '进件失败', 6 => '审核中', 7 => '关闭', 8 => '进件成功'}

  def self.attr_writeable
    [
  		:full_name, :name, :appid, :mch_type, :industry, :memo,
      :wechat_channel_type, :alipay_channel_type,
  		:province, :urbn, :address,
      :bank_info, :legal_person, :company,
    ]
  end
  def self.attr_readable
    [
      :merchant_id, :id,
      :full_name, :name, :appid, :mch_type, :industry, :memo,
      :province, :urbn, :address,
      :bank_info, :legal_person, :company,
    ]
  end
  def inspect
    {
      id: id.to_s,
      merchant_id: merchant_id,
      status: STATUS_DATA[status],
      full_name: full_name,
      name: name,
      memo: memo,
      province: province,
      urbn: urbn,
      address: address,
      appid: appid,
      mch_type: mch_type,
      industry: industry,
      bank_info: bank_info.inspect,
      legal_person: legal_person.inspect,
      company: company.inspect,
      request_and_response: request_and_response.inspect,
    }
  end
end

class LegalPerson < ApplicationRecord
  include Imagable
  embedded_in :merchant
  field :identity_card_front_key, type: String    # 身份证正面
  field :identity_card_back_key, type: String    # 身份证反面  
  field :tel, type: String               # 联系人电话
  field :name, type: String              # 联系人名称
  field :email, type: String             # 联系人邮箱
  field :identity_card_num, type: String # 身份证号
  def inspect
    {
      identity_card_front_key: identity_card_front_key,
      identity_card_back_key: identity_card_back_key,
      tel: tel,
      name: name,
      email: email,
      identity_card_num: identity_card_num,
    }
  end
end

class Company < ApplicationRecord
  include Imagable
  embedded_in :merchant

  field :shop_picture_key, type: String  # 店铺照
  field :license_key, type: String   # 营业执照
  field :contact_tel, type: String  # 联系人电话
  field :contact_name, type: String # 联系人姓名
  field :service_tel, type: String  # 客服电话
  field :contact_email, type: String# 联系人邮箱
  field :license_code, type: String # 营业执照编码
  def inspect
    {
      shop_picture_key: shop_picture_key,
      license_key: license_key,
      contact_tel: contact_tel,
      contact_name: contact_name,
      service_tel: service_tel,
      contact_email: contact_email,
      license_code: license_code,
    }
  end
end

class BankInfo < ApplicationRecord
  embedded_in :merchant
  field :owner_name, type: String # 账户名称（账号名）
  # field :bank_name, type: String # 开户行检称（中文名）
  field :bank_sub_code, type: String # 支付联行号
  field :account_num, type: String # 账号
  field :account_type, type: String # 账户类型(个人，企业)
  field :owner_idcard, type: String # 持卡人身份证号码
  field :province, type: String # 开户省
  field :urbn, type: String # 开户市
  field :zone, type: String # 开户区
  field :bank_full_name, type: String # 银行全称

  def inspect
    {
      owner_name: owner_name, # 账户名称（账号名）
      # bank_name: bank_name, # 开户行检称（中文名）
      bank_sub_code: bank_sub_code, # 支付联行号
      account_num: account_num, # 账号
      account_type: account_type, # 账户类型(个人，企业)
      owner_idcard: owner_idcard, # 持卡人身份证号码
      province: province, # 开户省
      urbn: urbn, # 开户市
      zone: zone, # 开户区
      bank_full_name: bank_full_name, # 银行全称
    }
  end
end

class RequestAndResponse < ApplicationRecord
  embedded_in :merchant
  field :zx_request, type: Hash # 中信进件内容
  field :zx_reponse, type: Hash # 中信进件内容
  def inspect
    {
      zx_request: zx_request,
      zx_reponse: zx_reponse,
    }
  end
end
