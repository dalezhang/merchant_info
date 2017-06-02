# frozen_string_literal: true
module Biz
  class PfbInfcApi < IntfcBase
    def initialize(mch_id, channel)
      if mch_id.class == Merchant
        @merchant = mch_id
      elsif merchant = Merchant.find_by(merchant_id: mch_id)
        @merchant = merchant
      else
        raise 'merchant_id 无效'
      end
      raise "channel should be one of ['wechat_offline', 'wechat_app', 'alipay']" unless %w[wechat_offline wechat_app alipay].include?(channel)
      @channel = channel
      @pfb_request = @merchant.request_and_response['pfb_request'][@channel]
      raise 'pfb_request 无内容，请先生成进件请求' unless @pfb_request.present?
    end

    def send_intfc(req_typ)
      raise '请先生成进件请求。' if @pfb_request['outMchId'].size < 12
      js = nil
      case req_typ
      when '新增'
        js = prepare_request('CUSTOMER_ENTER')
      when '变更'
        js = prepare_request('CUSTOMER_UPDATE')
      when '查询'
        js = prepare_query
      else
        return log_error @merchant, '请求', '未知的请求类型'
      end
      if sent_request(js, req_typ)
        return "返回信息已保存在request_and_response.pfb_response.#{@channel}_#{req_typ}"
      end
      false
    end

    def prepare_request(req_typ)
      @pfb_request["serviceType"] = req_typ
      customer_num_from_enter = @merchant.request_and_response.pfb_response["#{@channel}_查询"]["customer_num"] rescue nil
      customer_num_from_query = @merchant.request_and_response.pfb_response["#{@channel}_查询"]["customer"]["customerNum"] rescue nil
      @pfb_request["customerNum"] = customer_num_from_enter || customer_num_from_query
      @pfb_request
    end

    def sent_request(js,req_typ)
      url = "#{Rails.application.secrets.biz['pfb']['infc_url']}/customer/service"
      agentNum = Rails.application.secrets.biz['pfb']['agent_num'] # 代理商编号
      key = Rails.application.secrets.biz['pfb']['agent_key'] # 代理商密钥
      sign = get_mac(js, key)
      js[:sign] = sign
      resp = HTTParty.post(url, body: js.to_json, follow_redirects: false)
      log_error @merchant, 'pfb sent_request', resp.body
      resp_hash = JSON.parse resp.body
      if resp_hash.present?
        resp['sign'] = '**'
        @merchant.request_and_response.pfb_response["#{@channel}_#{req_typ}"] = resp_hash
        @merchant.save
        unless resp_hash['return_code'] == '000000'
          return log_error @merchant, resp_hash['return_msg']
        end
      else
        return log_error @merchant, '无返回信息'
      end
      true
    end

    def prepare_query
      js = {
        serviceType: 'CUSTOMER_INFO',
        agentNum: Rails.application.secrets.biz['pfb']['agent_num'],
        queryType: '1', # 值为：0/1
        customerNum: nil, # 查询条件类型为0时必填
        outMchId: "#{@channel}_#{@merchant.merchant_id}", # 查询条件类型为1时必填
      }
    end

    private

    def get_mab(js)
      mab = []
      js.keys.sort.each do |k|
        mab << "#{k}=#{js[k]}" if k != :mac && k != :sign && js[k]
      end
      mab.join('&')
    end

    def get_mac(js, key)
      Digest::MD5.hexdigest(get_mab(js).to_s + key.to_s).upcase
    end
  end
end
