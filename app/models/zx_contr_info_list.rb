# frozen_string_literal: true

class ZxContrInfoList < ApplicationRecord
  embedded_in :merchant
  # 支付类型编码：
  # 支付宝:
  # 00010001-----条码支付
  # 00010002-----扫码支付
  # 00010003-----无线支付
  # 微信支付:
  # 00020001-----公众号支付（JSAPI）
  # 00020002-----原生扫码支付（NATIVE）
  # 00020003-----APP支付（APP）
  # 00020004-----刷卡支付（MICROPAY）
  PayTypData = {
    '00010001' => '(支付宝)条码支付',
    '00010002' => '(支付宝)扫码支付',
    '00010003' => '(支付宝)无线支付',
    '00020001' => '(微信支付)JSAPI',
    '00020002' => '(微信支付)NATIVE',
    '00020003' => '(微信支付)APP',
    '00020004' => '(微信支付)MICROPAY'
  }.freeze

  field :pay_typ_encd # 支付类型编码
  field :pay_typ_fee_rate # 支付类型费率，指定支付类型的商户签约费率（商户交易总扣除费率），费率标准请与业务负责人沟通。
  field :start_dt # 费率生效日期，请填写商户入驻申请日当日或之后的日期，即不可填写历史日期。
  def inspect
    {
      id: id.to_s,
      pay_typ_encd: pay_typ_encd,
      pay_typ_fee_rate: pay_typ_fee_rate,
      start_dt: start_dt
    }
  end
end
