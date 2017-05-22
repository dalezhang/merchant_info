# frozen_string_literal: true

require 'httparty'
module Biz
  class CoreAccount < IntfcBase
    def initialize(merchant)
      @merchant = merchant
      @error = nil
    end
    def create_backend_account
      return @merchant.merchant_id if @merchant.merchant_id
      params = {
        partner_id: 'merchant_info',
        partner_mch_id: @merchant.partner_mch_id,
        # public_key: merchant.id.to_s
      }
      response = backend_account 'post', 'cms/merchants/', params.to_json
      if response['code'] == 0
        @merchant.update_attributes(merchant_id: response['data'])
        return true
      else
        return log_error @merchant, 'CoreAccount', response['msg']
      end
    end
    # def get_backend_account(merchant)
    #   response = HTTParty.try('get', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8")
    # end

    # def update_backend_account(merchant)
    #   response = HTTParty.try('put', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8", body: {public_key: '123'}.to_json)
    # end

    # def delete_backend_account(merchant)
    #   response = HTTParty.try('delete', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8")
    # end


    def backend_account(action, url, params)
      begin
        response = HTTParty.try(action, "http://zt-t.pooulcloud.cn/#{url}", body: params)
      rescue Exception # Errno::ECONNREFUSED, Net::OpenTimeout => e
        response = {
          code: 502,
          message: 'connect to upstream server error'
        }.to_json
      end
      puts response.body
      JSON.parse response.body
    end
  end
end
