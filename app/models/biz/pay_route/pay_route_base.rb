# frozen_string_literal: true
# 支付网管
class Biz::PayRoute::PayRouteBase
  def initialize(mch)
    @host = "http://120.77.180.208:3001/cms/routes"
    host = Rails.application.secrets.core['host']
    raise 'Rails.application.secrets.core["host"] is not set' unless host.present?
    @url = host + '/cms/routes'
    if mch.class == Merchant
      @merchant = mch
    elsif merchant = Merchant.find(mch)
      @merchant = merchant
    else
      raise 'merchant 无效'
    end
  end

  def create_backend_account(params)
    response = backend_account 'post',  params.to_json
    response.body
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

  def create_routes(js)
    host = "http://120.77.180.208:3001/cms/routes"
    response = HTTParty.try('post', "#{host}", body: js.to_json)
    response.body
  end
end
