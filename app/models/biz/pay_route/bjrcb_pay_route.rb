# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::BjrcbPayRoute < Biz::PayRoute::PayRouteBase
  attr_reader :query_result

  def initialize(merchant, channel_type)
    super
    @query_result = @merchant.request_and_response[:pfb_response].deep_symbolize_keys rescue nil
    unless @query_result.present?
      raise "@merchant.request_and_response[:pfb_request] is nil"
    end
  end

  def send_wechat_offline
    query_customer_num = @query_result[:wechat_offline_查询][:customer][:customerNum] rescue nil
    response_customer_num = @query_result[:wechat_offline_新增][:customer_num] rescue nil
    customer_num = response_customer_num || query_customer_num
    query_api_key = @query_result[:wechat_offline_查询][:customer][:apiKey] rescue nil
    response_api_key = @query_result[:wechat_offline_新增][:api_key] rescue nil
    api_key = response_api_key || query_api_key
    channel_type = @channel_type
    unless customer_num.present?
      raise "can't find customerNum in merchant.request_and_response[:pfb_request]"
    end
    unless api_key.present?
      raise "can't find apiKey in @merchant.request_and_response[:pfb_request]"
    end
    hash = {
			#通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
			#channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
			#channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_name: 'BJRCB',
      channel_mch_id: customer_num,
			channel_key: api_key,                   #在通道开户获得的key
      channel_type: channel_type, # 结算方式
      pay_type: ["wechat.scan", "wechat.jsapi", "wechat.micro"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
      priority: 1,
    }
    create_route_request(hash)
    data = send_request # @request_js
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route][:wechat_offline] = @request_js
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route][:wechat_offline] = data
    unless data[:code] == 0
      raise data.to_json
    end
	end

  def send_alipay
    query_customer_num = @query_result[:alipay_查询][:customer][:customerNum] rescue nil
    response_customer_num = @query_result[:alipay_新增][:customer_num] rescue nil
    customer_num = response_customer_num || query_customer_num
    query_api_key = @query_result[:alipay_查询][:customer][:apiKey] rescue nil
    response_api_key = @query_result[:alipay_新增][:api_key] rescue nil
    api_key = response_api_key || query_api_key
    unless customer_num.present?
      raise "can't find customerNum in @merchant.request_and_response[:pfb_request]"
    end
    unless api_key.present?
      raise "can't find apiKey in @merchant.request_and_response[:pfb_request]"
    end
    hash = {
      channel_name: 'BJRCB',
      channel_mch_id: customer_num,
			channel_key: api_key,                   #在通道开户获得的key
      pay_type: ["alipay.scan", "alipay.micro"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
      priority: 1,
    }
    create_route_request(hash)
    data = send_request # @request_js
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_request[:bjrbc_pay_route][:alipay] = @request_js
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route] ||= {}
    @merchant.request_and_response.pfb_response[:bjrbc_pay_route][:alipay] = data
    unless data[:code] == 0
      raise data.to_json
    end
	end
end
