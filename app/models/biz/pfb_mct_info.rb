# frozen_string_literal: true
require 'net/ftp'
class Biz::PfbMctInfo
  SettleModes = {'T0_实时': 'T0_INSTANT', 'T0_批量': 'T0_BATCH', 'T0_手动': 'T0_HANDING', 'T1_自动': 'T1_AUTO'}
  def initialize(merchant)
    raise 'merchant require' unless merchant.class == Merchant
    @merchant = merchant
    @salt = @merchant.id.to_s
    @serviceType = nil # 业务类型
    @agentNum = Rails.application.secrets.biz['pfb']['agent_num']  # 代理商编号
    @outMchId = nil # 下游商户号(唯一),可用于查询商户信息
    @customerType = pfb_customer_type(@merchant.mch_type.try(:strip)) # 个体：PERSONAL 企业：ENTERPRISE
    @businessType =  nil # 详见:经营行业列表
    @customerName = @merchant.full_name.try(:strip) # 商户名称
    @businessName = @merchant.name.try(:strip) # 支付成功显示
    @legalId = @merchant.legal_person.identity_card_num.try(:strip) # 法人身份证号
    @legalName = @merchant.legal_person.name.try(:strip) # 法人名称
    @contact = @merchant.company.contact_name.try(:strip) # 联系人
    @contactPhone = @merchant.company.contact_tel.try(:strip) # 联系人电话
    @contactEmail = @merchant.company.contact_email.try(:strip) # 联系人邮箱
    @servicePhone = @merchant.company.service_tel.try(:strip) # 客服电话
    @address = [@merchant.province.try(:strip), @merchant.urbn.try(:strip), @merchant.address.try(:strip)].join(',') # 经营地址,企业商户必填
    @businessAddress =  @address  # 商户经营地址
    if @merchant.province.present?
      province = Location.where(location_name: Regexp.new(@merchant.province.strip) ).first
      @provinceName = province.location_code if province.present? # 经营省,企业商户必填
      if @provinceName.present? && @merchant.urbn.present?
        urbn = Location.where(pub_location_code: @provinceName, location_name: Regexp.new(@merchant.urbn.strip) ).first
        @cityName = urbn.location_code if urbn.present? # 经营市,企业商户必填
        if @cityName.present? && @merchant.zone.present?
          zone = Location.where(pub_location_code: @cityName, location_name: Regexp.new(@merchant.zone.strip) ).first
          if zone.present?
            @districtName = zone.location_code # 经营区,企业商户必填
          else
            @districtName = Location.where(pub_location_code: @cityName ).first.try(:location_code)
          end
        end
      end
    end
    @licenseNo = @merchant.company.license_code.try(:strip) # 营业执照编号,企业商户必填
    @payChannel = nil # 支付通道类型
    @rate = nil # 交易费率,百分比，0.5为千五
    @t0Status = nil # 是否开通T+0, 开通：Y／关闭：N
    @settleRate = 0 # T+0费率,百分比，0.5为千五,实际费率为T1(rate)+T0(t0Status),T1+T0=结算价
    @fixedFee = 0 # T+0单笔加收费用,单位：元（未开通T+0 填写0)
    @isCapped = nil # 是否封顶,封顶：Y／不封顶：N
    @settleMode = nil # 结算模式,查看结算模式
    @upperFee = 0 # 封顶值, 单位：元，当IS_CAPPED为Y时，否则请填写0
    @accountType = pfb_account_type(@merchant.bank_info.account_type.try(:strip)) # 银行卡账户类型,个体户：PERSONAL 公户：COMPANY
    @accountName = @merchant.bank_info.owner_name.try(:strip) # 开户名,银行开户名称
    @bankCard = @merchant.bank_info.account_num.try(:strip) # 银行卡号
    @bankName = @merchant.bank_info.bank_full_name.try(:strip)  # 开户行名称
    @province = @merchant.bank_info.province.try(:strip) # 开户行省份
    @city = @merchant.bank_info.urbn.try(:strip) # 开户行城市
    @bankAddress = @merchant.bank_info.bank_full_name.try(:strip) # 开户行支行
    @alliedBankNo = @merchant.bank_info.bank_sub_code.try(:strip) # 联行号,否则会影响结算
    @appId = @merchant.appid.try(:strip) # 公众号ID
    @rightID = "/#{@salt}/#{@merchant.legal_person.identity_card_front_key.try(:strip)}" # 身份证正面
    @reservedID = "/#{@salt}/#{@merchant.legal_person.identity_card_back_key.try(:strip)}" # 身份证反面
    @IDWithHand = "/#{@salt}/#{@merchant.legal_person.id_with_hand_key.try(:strip)}" # 手持身份证
    @rightBankCard = "/#{@salt}/#{@merchant.bank_info.right_bank_card_key.try(:strip)}" # 银行卡正面
    @licenseImage = "/#{@salt}/#{@merchant.company.license_key.try(:strip)}" # 营业执照
    @doorHeadImage = "/#{@salt}/#{@merchant.company.shop_picture_key.try(:strip)}" # 门面照
    @accountLicence = "/#{@salt}/#{@merchant.company.account_licence_key.try(:strip)}" # 开户许可证
  end

  def pfb_account_type(account_type)
    if account_type =~ /对私/ || account_type =~ /个人/ || account_type =~ /个体/
      'PERSONAL'
    elsif account_type =~ /对公/ || account_type =~ /企业/
      'COMPANY'
    end
  end

  def pfb_customer_type(account_type)
    if account_type =~ /对私/ || account_type =~ /个人/ || account_type =~ /个体/
      'PERSONAL'
    elsif account_type =~ /对公/ || account_type =~ /企业/
      'ENTERPRISE'
    end
  end

  def prepare_request
    upload_relate_pictures
    wechat_offline = @merchant.channel_data['pfb'].try(:[],'wechat_offline')
    wechat_app = @merchant.channel_data['pfb'].try(:[],'wechat_app')
    alipay = @merchant.channel_data['pfb'].try(:[],'alipay')
    pfb_request = {}
    {
      wechat_offline: {
        outMchId: @salt,
        payChannel: 'WECHAT_OFFLINE',
        rate: wechat_offline.try(:[],'rate'),
        t0Status: wechat_offline.try(:[],'t0Status'),
        settleRate: wechat_offline.try(:[],'settleRate'),
        fixedFee: wechat_offline.try(:[],'fixedFee'),
        isCapped: wechat_offline.try(:[],'isCapped'),
        upperFee: wechat_offline.try(:[],'upperFee'),
        settleMode: wechat_offline.try(:[],'settleMode'),
        businessType: @merchant.wechat_channel_type_lv2.try(:strip),
      },
      # 暂时不需要
      # wechat_app: {
      #   outMchId: @salt,
      #   payChannel: 'WECHAT_APP',
      #   rate: wechat_app.try(:[],'rate'),
      #   t0Status: wechat_app.try(:[],'t0Status'),
      #   settleRate: wechat_app.try(:[],'settleRate'),
      #   fixedFee: wechat_app.try(:[],'fixedFee'),
      #   isCapped: wechat_app.try(:[],'isCapped'),
      #   upperFee: wechat_app.try(:[],'upperFee'),
      #   settleMode: wechat_app.try(:[],'settleMode'),
      #   businessType: @merchant.wechat_channel_type_lv2,
      # },
      alipay: {
        outMchId: @salt,
        payChannel: 'ALIPAY',
        rate: alipay.try(:[],'rate'),
        t0Status: alipay.try(:[],'t0Status'),
        settleRate: alipay.try(:[],'settleRate'),
        fixedFee: alipay.try(:[],'fixedFee'),
        isCapped: alipay.try(:[],'isCapped'),
        upperFee: alipay.try(:[],'upperFee'),
        settleMode: alipay.try(:[],'settleMode'),
        businessType: @merchant.alipay_channel_type_lv1.try(:strip),
      },
    }.each do |key, value|
      @outMchId = value[:outMchId]
      @payChannel = value[:payChannel]
      @rate = value[:rate]
      @t0Status = value[:t0Status]
      @settleRate = value[:settleRate]
      @fixedFee = value[:fixedFee]
      @isCapped = value[:isCapped]
      @upperFee = value[:upperFee]
      @settleMode = value[:settleMode]
      @businessType = value[:businessType]
      pfb_request[key] = inspect
    end
    @merchant.request_and_response.pfb_request = pfb_request
    unless @merchant.save
      raise @merchant.errors.full_messages.join("\n")
    end
    true
  end

  def upload_relate_pictures
    [
      @merchant.legal_person.identity_card_front_key.try(:strip),# 身份证正面
      @merchant.legal_person.identity_card_back_key.try(:strip), # 身份证反面
      @merchant.legal_person.id_with_hand_key.try(:strip), # 手持身份证
      @merchant.bank_info.right_bank_card_key.try(:strip), # 银行卡正面
      @merchant.company.license_key.try(:strip), # 营业执照
      @merchant.company.shop_picture_key.try(:strip), # 门面照
      @merchant.company.account_licence_key.try(:strip), # 农商行，开户许可证
    ].each do |key|
      if key.present?
        @merchant.channel_data['pfb'] ||= {}
        unless @merchant.channel_data['pfb']['identity_card_front_key'] == key
          if upload_picture(key)
            @merchant.channel_data['pfb']['identity_card_front_key'] = key
          end
        end
      end
    end
  end

  def upload_picture(key)
    raise "bucket_url 不能为空" unless @merchant.user.bucket_url.present?
    ftp = Net::FTP.new('60.205.203.64', 'A147920196116310531', 'A]ke7))}W=O-76,9?i')
    ftp.chdir("/")
    if ftp.nlst.include?(@salt)
      ftp.chdir("/#{@salt}/")
    else
      ftp.mkdir("/#{@salt}/")
      ftp.chdir("/#{@salt}/")
    end
    ftp.putbinaryfile("#{@merchant.user.bucket_url}/#{key}")
    ftp.close
  end

  def inspect
    {
      serviceType: @serviceType.try(:strip), # 业务类型
      agentNum: @agentNum.try(:strip),
      outMchId: @outMchId.try(:strip), # 下游商户号(唯一),可用于查询商户信息
      customerType: @customerType, # 个体：PERSONAL 企业：ENTERPRISE
      businessType: @businessType.try(:strip), # 详见:经营行业列表
      customerName: @customerName.try(:strip), # 商户名称
      businessName: @businessName.try(:strip), # 支付成功显示
      legalId: @legalId.try(:strip), # 法人身份证号
      legalName: @legalName.try(:strip), # 法人名称
      contact: @contact.try(:strip), # 联系人
      contactPhone: @contactPhone.try(:strip), # 联系人电话
      contactEmail: @contactEmail.try(:strip), # 联系人邮箱
      servicePhone: @servicePhone.try(:strip), # 客服电话
      address: @address, # 经营地址,企业商户必填
      businessAddress: @businessAddress,
      provinceName: @provinceName, # 经营省,企业商户必填
      cityName: @cityName, # 经营市,企业商户必填
      districtName: @districtName, # 经营区,企业商户必填
      licenseNo: @licenseNo.try(:strip), # 营业执照编号,企业商户必填
      payChannel: @payChannel.try(:strip), # 支付通道类型
      rate: @rate, # 交易费率,百分比，0.5为千五
      t0Status: @t0Status, # 是否开通T+0, 开通：Y／关闭：N
      settleRate: @settleRate, # T+0费率,百分比，0.5为千五
      fixedFee: @fixedFee, # T+0单笔加收费用,单位：元（未开通T+0 填写0)
      isCapped: @isCapped, # 是否封顶,封顶：Y／不封顶：N
      settleMode: @settleMode.try(:strip), # 结算模式,查看结算模式
      upperFee: @upperFee, # 封顶值, 单位：元，当IS_CAPPED为Y时，否则请填写0
      accountType: @accountType.try(:strip), # 银行卡账户类型,个体户：PERSONAL 公户：COMPANY
      accountName: @accountName.try(:strip), # 开户名,银行开户名称
      bankCard: @bankCard.try(:strip), # 银行卡号
      bankName: @bankName.try(:strip), # 开户行名称
      province: @province.try(:strip), # 开户行省份
      city: @city.try(:strip), # 开户行城市
      bankAddress: @bankAddress.try(:strip), # 开户行支行
      alliedBankNo: @alliedBankNo.try(:strip), # 联行号,否则会影响结算
      rightID: @rightID.try(:strip), # 身份证正面
      reservedID: @reservedID.try(:strip), # 身份证反面
      IDWithHand: @IDWithHand.try(:strip), # 手持身份证
      rightBankCard: @rightBankCard.try(:strip), # 银行卡正面
      licenseImage: @licenseImage.try(:strip), # 营业执照
      doorHeadImage: @doorHeadImage.try(:strip), # 门面照
      accountLicence: @accountLicence.try(:strip), # 开户许可证
      appId: @appId.try(:strip),
    }
  end
end
