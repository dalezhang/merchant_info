# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::ZxAlipayPayRoute < Biz::PayRoute::PayRouteBase
  attr_reader :query_result

  def initialize(merchant, channel_type = nil)
    super
    @query_result = @merchant.request_and_response.zx_response.deep_symbolize_keys rescue nil
    unless @query_result.present?
      raise "@merchant.request_and_response[:zx_response] is nil"
    end
  end

  def send_wechat
    query_channel_key = @query_result[:wechat_query][:ROOT][:Mercht_Idtfy_Num] rescue nil
    unless query_channel_key.present?
      raise "can't find query_channel_key in merchant.request_and_response[:zx_response]"
    end
    hash = {
      channel_name:  "CITIC_WECHAT",
      #通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
      #channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
      #channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_key: nil,
      channel_mch_id: query_channel_key,
      channel_type: 1, # 结算方式,T1
      pay_type: ["wechat.scan", "wechat.jsapi", "wechat.micro"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
      priority: 1,
    }
    create_route_request(hash)
    data = send_request # @request_js
    log_js = {
      model: 'Biz::PayRoute::ZxAlipayPayRoute',
      method: 'send_wechat',
      merchant: @merchant.id.to_s,
      request_hash: hash.to_s,
      response_hash: data.to_s,
    }
    log_es(log_js)
    unless data[:code] == 0
      raise data.to_json
    end
  end


  def send_alipay
    query_channel_key = @query_result[:alipay_query][:ROOT][:Mercht_Idtfy_Num]
    unless query_channel_key.present?
      raise "can't find query_channel_key in merchant.request_and_response[:zx_response]"
    end
		hash = {
			channel_name:  "CITIC_ALI",
			#通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
			#channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
			#channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_key: query_channel_key,
			channel_mch_id: nil,
      channel_type: 1, # 结算方式,T1
			pay_type: ["alipay.scan","alipay.micro","alipay.jsapi"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
			priority: 1,
		}
    create_route_request(hash)
    data = send_request # @request_js
    log_js = {
      model: 'Biz::PayRoute::ZxAlipayPayRoute',
      method: 'send_alipay',
      merchant: @merchant.id.to_s,
      request_hash: hash.to_s,
      response_hash: data.to_s,
    }
    log_es(log_js)
    unless data[:code] == 0
      raise data.to_json
    end
	end


end
