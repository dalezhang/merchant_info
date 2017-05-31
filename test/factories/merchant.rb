FactoryGirl.define do
  factory :merchant do
    user_id ''
    status '状态'
    full_name '商户全名称'
    name '商户简称'
    memo '商户备注'
    province '省份（字典'
    urbn  '城市（汉字标示'
    address '详细地址'
    appid '公众号'
    mch_type '商户类型(个体，企业)'
    industry '经营行业'
    pfb_channel_type '普付宝经营类目' # 见附件《经营类目》中的经营类目明细编码
    
    #银行信息
    bank_info {{
        owner_name: 'owner_name', # 账户名称（账号名）
        bank_sub_code: 'bank_sub_code', # 支付联行号
        account_num: 'account_num', # 账号
        account_type: '个人', # 账户类型(个人，企业)
        owner_idcard: 'owner_idcard', # 持卡人身份证号码
        province: 'province', # 开户省
        urbn: 'urbn', # 开户市
        zone: 'zone', # 开户区
        bank_full_name: 'bank_full_name', # 银行全称
    }}
    # 法人信息
    legal_person {{
        identity_card_front_key: 'identity_card_front_key', # 身份证正面
        identity_card_back_key: 'identity_card_back_key',  # 身份证反面  
        tel: 'tel', # 联系人电话
        name: 'name', # 联系人名称
        email: 'email', # 联系人邮箱
        identity_card_num: 'identity_card_num', # 身份证号
    }}
    # 公司信息
    company {{
        shop_picture_key: 'shop_picture_key', # 店铺照
        license_key: 'license_key', # 营业执照
        contact_tel: 'contact_tel', # 联系人电话
        contact_name: 'contact_name', # 联系人姓名
        service_tel: 'service_tel', # 客服电话
        contact_email: 'contact_email', # 联系人邮箱
        license_code: 'license_code', # 营业执照编码
    }}
  end

end
