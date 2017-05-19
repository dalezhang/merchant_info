# frozen_string_literal: true

require 'httparty'
module Biz
  module CoreAccount
    extend self
    def create_backend_account(merchant)
      return true if merchant.merchant_id
      params = {
        partner_id: 'merchant_info',
        partner_mch_id: merchant.id.to_s,
        # public_key: merchant.id.to_s
      }
      response = backend_account 'post', 'cms/merchants/', params.to_json
      if response[:code] == 0
        merchant.update_attributes(merchant_id: response[:data])
        puts "response is #{account.merchant_id}"
        return true
      else
        return false
      end
    end
    def get_backend_account(merchant)
      response = HTTParty.try('get', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8")
    end

    def update_backend_account(merchant)
      response = HTTParty.try('put', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8", body: {public_key: '123'}.to_json)
    end

    def delete_backend_account(merchant)
      response = HTTParty.try('delete', "http://zt-t.pooulcloud.cn/cms/merchants/590fe5d7ffea0e5f6dcb3ab8")
    end


    def backend_account(action, url, params)
      binding.pry
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
