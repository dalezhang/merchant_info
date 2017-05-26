# frozen_string_literal: true

class Biz::PfbMctInfo
  # def initialize(merchant)
  #   raise 'merchant require' unless merchant.class == Merchant
  #   @merchant = merchant
  #   @serviceType = 'CUSTOMER_ENTER', # 业务类型
  #   @agentNum = 'A147860093307610145',  # 代理商编号
  #   @outMchId = @merchant.merchant_id, # 下游商户号(唯一),可用于查询商户信息
  #   @customerType = pfb_account_type(@merchant.bank_info.account_type), # 个体：PERSONAL 企业：ENTERPRISE
  #   @businessType =  @merchant.pfb_channel_type, # 详见:经营行业列表
  #   @customerName = @merchant.full_name, # 商户名称
  #   @businessName = @merchant.name, # 支付成功显示
  #   @legalId = @merchant.legal_person.identity_card_num, # 法人身份证号
  #   @legalName: @merchant.legal_person.name, # 法人名称
  #   @contact: @merchant.full_name, # 联系人
  #   @contactPhone: @merchant.company.contact_tel, # 联系人电话
  #   @contactEmail: @merchant.company.contact_email, # 联系人邮箱
  #   @servicePhone: @merchant.company.service_tel, # 客服电话
  #   @address: [@merchant.province, @merchant.urbn, @merchant.address].join(','), # 经营地址,企业商户必填
  #   @provinceName: @merchant.province, # 经营省,企业商户必填
  #   @cityName: @merchant.urbn, # 经营市,企业商户必填
  #   @districtName: @merchant.address, # 经营区,企业商户必填
  #   @licenseNo: @merchant.company.license_code, # 营业执照编号,企业商户必填
  #   @payChannel: nil, # 支付通道类型
  #   @rate: nil, # 交易费率,百分比，0.5为千五
  #   @t0Status: 'Y', # 是否开通T+0, 开通：Y／关闭：N
  #   @settleRate: 0.5, # T+0费率,百分比，0.5为千五
  #   @fixedFee: 2, # T+0单笔加收费用,单位：元（未开通T+0 填写0)
  #   @isCapped: 'N', # 是否封顶,封顶：Y／不封顶：N
  #   @settleMode: 'T0_BATCH', # 结算模式,查看结算模式
  #   @upperFee: 0, # 封顶值, 单位：元，当IS_CAPPED为Y时，否则请填写0
  #   @accountType: 'COMPANY', # 银行卡账户类型,个体户：PERSONAL 公户：COMPANY
  #   @accountName: '张三', # 开户名,银行开户名称
  #   @bankCard: '124125412513516', # 银行卡号
  #   @bankName: '1234125412', # 开户行名称
  #   @province: '广东', # 开户行省份
  #   @city: '深圳', # 开户行城市
  #   @bankAddress: '招商银行深圳泰然金谷支行', # 开户行支行
  #   @alliedBankNo: '308584001258', # 联行号,否则会影响结算
  #   @rightID: '123', # 身份证正面
  #   @reservedID: '1243', # 身份证反面
  #   @IDWithHand: '123', # 手持身份证
  #   @rightBankCard: '123', # 银行卡正面
  #   @licenseImage: '123', # 营业执照
  #   @doorHeadImage: '123', # 门面照
  #   @accountLicence: '123', # 开户许可证
  # end

  # def pfb_account_type(account_type)
  #   if account_type =~ /对私/ || account_type =~ /个人/
  #     'PERSONAL'
  #   elsif account_type =~ /对公/ || account_type =~ /企业/
  #     'ENTERPRISE'
  #   end
  # end
  # def prepare_request
  #   raise 'merchant_id为空' unless @merchant.merchant_id.present?
  #   pfb_request = {}
  #   {
  #     wechat_offline: {
  #       payChannel: 'WECHAT_OFFLINE',
  #       rate: @merchant.channel_data.pfb['wechat_offline']['rate'],
  #     },
  #     wechat_app: {
  #       payChannel: 'WECHAT_APP',
  #       rate: @merchant.channel_data.pfb['wechat_app']['rate'],
  #     },
  #     alipay: {
  #       payChannel: 'ALIPAY',
  #       rate: @merchant.channel_data.pfb['alipay']['rate'],
  #     }

  #   }.each do |key, value|
  #     @payChannel = value[:payChannel]
  #     @rate = value[:rate]
  #     pfb_request[key] = inspect
  #   end
  #   @merchant.request_and_response.pfb_request = pfb_request
  #   @merchant.save
  # end


  # def inspect
  #   js = {
  #     serviceType: 'CUSTOMER_ENTER', # 业务类型
  #     agentNum: agentNum,
  #     outMchId: merchant_id, # 下游商户号(唯一),可用于查询商户信息
  #     customerType: 'ENTERPRISE', # 个体：PERSONAL 企业：ENTERPRISE
  #     businessType: '203', # 详见:经营行业列表
  #     customerName: 'test1', # 商户名称
  #     businessName: '123', # 支付成功显示
  #     legalId: '620202198901190032', # 法人身份证号
  #     legalName: '张三', # 法人名称
  #     contact: '张三', # 联系人
  #     contactPhone: '13800138000', # 联系人电话
  #     contactEmail: 'example@mail.cn', # 联系人邮箱
  #     servicePhone: '13800138000', # 客服电话
  #     address: '123', # 经营地址,企业商户必填
  #     provinceName: '广东', # 经营省,企业商户必填
  #     cityName: '深圳', # 经营市,企业商户必填
  #     districtName: '宝安', # 经营区,企业商户必填
  #     licenseNo: '12345jnkljasdkfg', # 营业执照编号,企业商户必填
  #     payChannel: 'WECHAT_OFFLINE', # 支付通道类型
  #     rate: 0.5, # 交易费率,百分比，0.5为千五
  #     t0Status: 'Y', # 是否开通T+0, 开通：Y／关闭：N
  #     settleRate: 0.5, # T+0费率,百分比，0.5为千五
  #     fixedFee: 2, # T+0单笔加收费用,单位：元（未开通T+0 填写0)
  #     isCapped: 'N', # 是否封顶,封顶：Y／不封顶：N
  #     settleMode: 'T0_BATCH', # 结算模式,查看结算模式
  #     upperFee: 0, # 封顶值, 单位：元，当IS_CAPPED为Y时，否则请填写0
  #     accountType: 'COMPANY', # 银行卡账户类型,个体户：PERSONAL 公户：COMPANY
  #     accountName: '张三', # 开户名,银行开户名称
  #     bankCard: '124125412513516', # 银行卡号
  #     bankName: '1234125412', # 开户行名称
  #     province: '广东', # 开户行省份
  #     city: '深圳', # 开户行城市
  #     bankAddress: '招商银行深圳泰然金谷支行', # 开户行支行
  #     alliedBankNo: '308584001258', # 联行号,否则会影响结算
  #     rightID: '123', # 身份证正面
  #     reservedID: '1243', # 身份证反面
  #     IDWithHand: '123', # 手持身份证
  #     rightBankCard: '123', # 银行卡正面
  #     licenseImage: '123', # 营业执照
  #     doorHeadImage: '123', # 门面照
  #     accountLicence: '123', # 开户许可证
  #   }
  # end
end