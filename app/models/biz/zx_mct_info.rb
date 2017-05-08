class Biz::ZxMctInfo
	attr_accessor :bank_account, :lics, :chnl_id, :full_name, :name, :contact_tel, 
		:contact_name, :service_tel, :contact_email, :memo, 
		:province, :urbn, :address, :owner_name, :bank_name,
    	:bank_sub_code, :account_num,
    :pay_chnl_encd
  def initialize(merchant)
    raise "merchant require" unless merchant
    @merchant = merchant
    @chnl_id = '10000022' # 商户归属渠道编号 ?
    @chnl_mercht_id = @merchant.merchant_id # 商户编号
    @pay_chnl_encd = nil # 支付宝：0001；微信支付：0002。注：商户开通多种支付渠道需分别提交进件申请
    @mercht_belg_chnl_id = '10000022' # 一般为渠道编号，多级渠道情况下为商户直属上级渠道编号
    @mercht_full_nm = @merchant.full_name #商户全名称
    @mercht_sht_nm = @merchant.name # 商户简称
    @cust_serv_tel = @merchant.company.service_tel # 客服电话
    @contcr_nm = @merchant.legal_person.name # 联系人名称
    @contcr_tel = @merchant.legal_person.tel # 联系人电话
    @contcr_mobl_num = @merchant.legal_person.tel # 联系人手机
    @contcr_eml = @merchant.legal_person.email # 联系人邮箱
    @opr_cls = @merchant.zx_channel_type # 根据不同支付渠道要求，填写相应经营类目。详细见附件《经营类目》中的经营类目明细编码
    @mercht_memo = @merchant.memo # 商户备注
    @prov = @merchant.province # 省份（字典
    @urbn = @merchant.urbn # 城市（汉字标示
    @dtl_addr = @merchant.address # 详细地址
    @acct_nm = @merchant.bank_info.owner_name # 开户人姓名/公司名
    @opn_bnk = @merchant.bank_info.bank_full_name # 开户行（中文名）
    @is_nt_citic = 0 # 是否中信银行,是：0，否：1
    @acct_typ =  zx_account_type(@merchant.bank_info.account_type)# 账户类型:1--中信银行对私账户，2--中信银行对公账户 3--中信银行内部账户，4--他行（非中信银行账户）
    @pay_ibank_num = @merchant.bank_info.bank_sub_code # 支付联行号
    @acct_num = @merchant.bank_info.account_num # 账号
    @is_nt_two_line = 0 # 是否支持收支两条线,否：0，是：1
  end

  def zx_account_type(account_type)
    if account_type =~ /对私/ || account_type =~ /个人/
      1
    elsif account_type =~ /对公/ || account_type =~ /企业/
      2
    end
  end

  def prepare_request
    zx_request = {}
    {wechat: '0002', alipay: '0001'}.each do |key,value|
      @pay_chnl_encd = value
      zx_request[key] = self.inspect
    end
    @merchant.request_and_response.zx_request = zx_request
    @merchant.save
  end

  def inspect
    {
      chnl_id: @chnl_id,
      chnl_merchant_id: @chnl_mercht_id,
      pay_chnl_encd: @pay_chnl_encd,
      mercht_belg_chnl_id: @mercht_belg_chnl_id,
      mercht_full_nm: @mercht_full_nm,
      mercht_sht_nm: @mercht_sht_nm,
      cust_serv_tel: @cust_serv_tel,
      contcr_nm: @contcr_nm,
      contcr_tel: @contcr_tel,
      contcr_eml: @contact_email,
      opr_cls: @opr_cls,
      mercht_memo: @mercht_memo,
      prov: @prov,
      urbn: @urbn,
      dtl_addr: @dtl_addr,
      acct_nm: @acct_nm,
      opn_bnk: @opn_bnk,
      is_nt_citic: @is_nt_citic,
      acct_typ: @acct_typ,
      pay_ibank_num: @pay_ibank_num,
      acct_num: @acct_num,
      is_nt_two_line: @is_nt_two_line
    }
  end
end
