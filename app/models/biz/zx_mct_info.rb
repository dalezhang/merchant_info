# frozen_string_literal: true

class Biz::ZxMctInfo
  def initialize(merchant)
    raise 'merchant require' unless merchant.class == Merchant
    @merchant = merchant
    @chnl_id = '10000022' # 商户归属渠道编号 ?
    @chnl_mercht_id = nil # 商户编号
    @pay_chnl_encd = nil # 支付宝：0001；微信支付：0002。注：商户开通多种支付渠道需分别提交进件申请
    @mercht_belg_chnl_id = '10000022' # 一般为渠道编号，多级渠道情况下为商户直属上级渠道编号
    @mercht_full_nm = @merchant.full_name # 商户全名称
    @mercht_sht_nm = @merchant.name # 商户简称
    @cust_serv_tel = @merchant.company.service_tel # 客服电话
    @contcr_nm = @merchant.legal_person.name # 联系人名称
    @contcr_tel = @merchant.legal_person.tel # 联系人电话
    @contcr_mobl_num = @merchant.legal_person.tel # 联系人手机
    @contcr_eml = @merchant.legal_person.email # 联系人邮箱
    @opr_cls = nil # 根据不同支付渠道要求，填写相应经营类目。详细见附件《经营类目》中的经营类目明细编码
    @mercht_memo = @merchant.memo # 商户备注
    @prov = @merchant.province # 省份（字典
    @urbn = @merchant.urbn # 城市（汉字标示
    @dtl_addr = @merchant.address # 详细地址
    @acct_nm = @merchant.bank_info.owner_name # 开户人姓名/公司名
    @opn_bnk = @merchant.bank_info.bank_full_name # 开户行（中文名）
    @is_nt_citic = @merchant.bank_info.is_nt_citic # 是否中信银行,是：0，否：1
    @acct_typ =  zx_account_type(@merchant.bank_info.account_type) # 账户类型:1--中信银行对私账户，2--中信银行对公账户 3--中信银行内部账户，4--他行（非中信银行账户）
    @pay_ibank_num = @merchant.bank_info.bank_sub_code # 支付联行号
    @acct_num = @merchant.bank_info.account_num # 账号
    @is_nt_two_line = 0 # 是否支持收支两条线,否：0，是：1
    @lics_file_url = "#{@merchant.user.bucket_url}/#{@merchant.company.license_key}"
    @zx_contr_info_lists = @merchant.zx_contr_info_lists.collect { |o| o.inspect}
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
    {
      wechat: {
        pay_chnl_encd: '0002',
        chnl_mercht_id: "zx_wechat_#{@merchant.merchant_id}",
        opr_cls: @merchant.zx_wechat_channel_type,
        zx_contr_info_lists: @merchant.zx_contr_info_lists.in(pay_typ_encd: ['00020001','00020002','00020003','00020004']),
      },
      alipay: {
        pay_chnl_encd: '0001',
        chnl_mercht_id: "zx_alipay_#{@merchant.merchant_id}",
        opr_cls: @merchant.zx_alipay_channel_type,
        zx_contr_info_lists: @merchant.zx_contr_info_lists.in(pay_typ_encd: ['00010001','00010002','00010003']),
      }

    }.each do |key, value|
      @pay_chnl_encd = value[:pay_chnl_encd]
      @chnl_mercht_id = value[:chnl_mercht_id]
      @opr_cls = value[:opr_cls]
      @zx_contr_info_lists = value[:zx_contr_info_lists].collect { |o| o.inspect}
      zx_request[key] = inspect
    end
    @merchant.request_and_response.zx_request = zx_request
    @merchant.save
  end

  def inspect
    {
      chnl_id: @chnl_id,
      chnl_mercht_id: @chnl_mercht_id,
      pay_chnl_encd: @pay_chnl_encd, # 支付宝：0001；微信支付：0002。注：商户开通多种支付渠道需分别提交进件申请
      mercht_belg_chnl_id: @mercht_belg_chnl_id,
      mercht_full_nm: @mercht_full_nm,
      mercht_sht_nm: @mercht_sht_nm,
      cust_serv_tel: @cust_serv_tel,
      contcr_nm: @contcr_nm,
      contcr_tel: @contcr_tel,
      contcr_mobl_num: @contcr_mobl_num,
      contcr_eml: @contcr_eml,
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
      is_nt_two_line: @is_nt_two_line,
      lics_file_url: @lics_file_url,
      zx_contr_info_lists: @zx_contr_info_lists,
    }
  end
end
