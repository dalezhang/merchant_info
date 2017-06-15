# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::BjrcbPayRoute < Biz::PayRoute::PayRouteBase
  attr_reader :query_result

  def initialize(merchant)
    super
    @query_result = @merchant.request_and_response[:pfb_request] rescue nil
    unless @query_result.present?
      raise "@merchant.request_and_response[:pfb_request] is nil"
    end
  end

  def send_wechat_offline
    out_mch_id =  @query_result[:wechat_offline][:outMchId] rescue nil
    unless out_mch_id.present?
      raise "can't find out_mch_id in @merchant.request_and_response[:pfb_request][:wechat_offline][:outMchId]"
    end
    hash = {
			#通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
			#channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
			#channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_name: 'BJRCB',
      channel_mch_id: @query_result[:wechat_offline][:outMchId],
      pay_type: ["wechat.scan", "wechat.jsapi", "wechat.micro"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
      priority: 1,
    }
    create_route_request(hash)
    data = send_request
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route][:wechat_offline] = @request_js
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route][:wechat_offline] = data
    unless data[:code] == 0
      raise data.to_json
    end
	end

end
