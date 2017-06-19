# frozen_string_literal: true
# 江南（json）商户信息接口，包含通过pertner_mch_id创建、查询merchant信息
# https://coding.net/t/pgate/p/test_api/git/blob/master/test/new_gate/merchant_id.rb

require 'httparty'
module Biz
  class CoreAccount < IntfcBase
    def initialize(merchant)
      @merchant = merchant
      @error = nil
      @url = 'http://zt-t.pooulcloud.cn'
    end

    def create_backend_account
      return @merchant.merchant_id if @merchant.merchant_id

      params = {
        partner_id: 'merchant_info',
        partner_mch_id: @merchant.partner_mch_id,
        public_key: @merchant.public_key,
      }
      response = backend_account 'post', 'cms/merchants/', params.to_json
      if response['code'] == 0
        @merchant.update_attributes(merchant_id: response['data'])
        return true
      else
        return log_error @merchant, 'CoreAccount->merchant_id', response['msg']
      end
    end
    def get_backend_account
      response = HTTParty.try('get', "http://zt-t.pooulcloud.cn/cms/merchants/#{@merchant.partner_mch_id}")
      
      if response['code'] == 0
        @merchant.request_and_response.core_account = response['data'][0]
        @merchant.merchant_id = @merchant.request_and_response.core_account['_id']
        @merchant.share_key = @merchant.request_and_response.core_account["share_key"]
        @merchant.save
      else
        return log_error @merchant, 'CoreAccount->merchant_id', response['msg']
      end
    end

    # def update_backend_account

    #   params = {
    #     public_key: @merchant.public_key,
    #   }
    #   #response = HTTParty.try('put', "http://zt-t.pooulcloud.cn/cms/merchants/#{@merchant.merchant_id}", body: params.to_json)
    #   response = backend_account 'put', "cms/merchants/#{@merchant.merchant_id}", params.to_json

    #   if response['code'] == 0
    #     return true
    #   else
    #     return log_error @merchant, 'CoreAccount->merchant_id', response['msg']
    #   end
    # end

    # def delete_backend_account(merchant)
    #   response = HTTParty.try('delete', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8")
    # end

    def backend_account(action, route, params)
      begin
        response = HTTParty.try(action, "#{@url}/#{route}", body: params)
      rescue Exception # Errno::ECONNREFUSED, Net::OpenTimeout => e
        response = {
          code: 502,
          message: 'connect to upstream server error'
        }.to_json
      end
      JSON.parse response.body
    end
  end
end
