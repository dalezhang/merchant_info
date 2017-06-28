# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::ZxAlipayPayRoute < Biz::PayRoute::PayRouteBase
  attr_reader :query_result

  def initialize(merchant, channel_type = nil)
    super
    @query_result = @merchant.request_and_response['zx_response']['alipay_query'] rescue nil
  end

  def create_route_request
    @zx_response = @merchant.request_and_response['zx_response']
		@request_js = {
			merchant_id: @merchant,             #merchant_id
			channel_name:  "citic_ali",
			#通道名称，SWIFT:威富通;BJRCB: 北京农商行;CITIC_ALI:中信直连支付宝;CITIC_WECHAT:中信直连微信;DIANZI:点子
			#channel_mch_id: "cccbbsdsdsdf",            #在通道开户获得的商户号
			#channel_key:"yyyyyyyyy",                   #在通道开户获得的key
      channel_key: @query_result["ROOT"]["Mercht_Idtfy_Num"],
			channel_mch_id: nil,
			pay_type: ["alipay.scan","alipay.micro","alipay.jsapi"], #该通道支持的支付方式,传入值为字符串，以分号分割不同类型
			priority: 1,
		}
	end

  def send_request
    response = HTTParty.try('post', @url, body: @request_js.to_json)
    response.body
    binding.pry
  end
	def get_backend_account(merchant_id)
		host =  "http://120.77.180.208:3001/cms/merchants/"
		response = HTTParty.try('get', "#{host}#{merchant_id}")
		response.body
	end
	def get_routes(merchant_id)
		host = "http://120.77.180.208:3001/cms/routes?merchant_id="
		response = HTTParty.try('get', "#{host}#{merchant_id}")
    response.body
    js = JSON.parse response.body
    js["data"].each {|c| puts c["_id"]}
    js.to_json
  end
  def put_routes(route_id, js)
    host = "http://120.77.180.208:3001/cms/routes/#{route_id}"
    response = HTTParty.try('put', "#{host}", body: js.to_json)
    response.body
  end

end
