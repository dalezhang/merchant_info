# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::PayRouteBase
  include Logging
  def initialize(mch, channel_type = nil)
    host = Rails.application.secrets.core['host'] rescue nil
    raise 'Rails.application.secrets.core["host"] is not set' unless host.present?
    @url = host + '/cms/routes'
    if mch.class == Merchant
      @merchant = mch
    elsif merchant = Merchant.find(mch) && merchant.present?
      @merchant = merchant
    else
      raise 'merchant 无效'
    end
  end

  def create_route_request(hash)
    hash.deep_symbolize_keys
		@request_js = {
      merchant_id: @merchant.merchant_id,             #merchant_id
			channel_name:  hash[:channel_name],
			#通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
			#channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
			#channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_key: hash[:channel_key],
      channel_type: hash[:channel_type], # 结算方式
			channel_mch_id: hash[:channel_mch_id],
			pay_type: hash[:pay_type], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
			priority: (hash[:priority] || 1),
		}
	end

  def query
    response = HTTParty.try('get', "#{@url}?merchant_id=#{@merchant.merchant_id}")
    response.body
    js = JSON.parse response.body
    @merchant.request_and_response.pay_route = js.deep_symbolize_keys
    @merchant.save!
  end

  def send_request
    response = HTTParty.try('post', @url, body: @request_js.to_json)
    data = JSON.parse response.body
    data.deep_symbolize_keys
  end
end
