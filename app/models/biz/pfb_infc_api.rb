# frozen_string_literal: true
module Biz
  class PfbInfcApi < IntfcBase
    def initialize(id, channel)
      if id.class == Merchant
        @merchant = id
      elsif merchant = Merchant.find(id)
        @merchant = merchant
      else
        raise 'Merchant 无效'
      end
      raise "channel should be one of ['wechat_offline', 'wechat_app', 'alipay']" unless %w[wechat_offline wechat_app alipay].include?(channel)
      @channel = channel
      @salt = @merchant.id.to_s
      @pfb_request = @merchant.request_and_response.pfb_request[@channel]
      raise "pfb_request.#{@channel} 无内容，请先生成进件请求。" unless @pfb_request.present?
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
      if req_typ == 'CUSTOMER_UPDATE'
        customer_num_from_enter = @merchant.request_and_response.pfb_response["#{@channel}_查询"]["customer_num"] rescue nil
        customer_num_from_query = @merchant.request_and_response.pfb_response["#{@channel}_查询"]["customer"]["customerNum"] rescue nil
        @pfb_request["customerNum"] = customer_num_from_enter || customer_num_from_query || ''
      end
      @pfb_request
    end

    def sent_request(js,req_typ)
      url = "#{Rails.application.secrets.biz['pfb']['infc_url']}/customer/service"
      agentNum = Rails.application.secrets.biz['pfb']['agent_num'] # 代理商编号
      key = Rails.application.secrets.biz['pfb']['agent_key'] # 代理商密钥
      sign = get_mac(js, key)
      js[:sign] = sign
      resp = HTTParty.post(url, body: js.to_json, follow_redirects: false)
      resp_hash = JSON.parse resp.body
      if resp_hash.present?
        log_js = {
            model: 'Biz::PfbInfcApi',
            method: 'sent_request',
            merchant: @merchant.id.to_s,
            request_hash: js.to_s, 
            response_hash: resp_hash.to_s,
        }
        log_es(log_js)
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
        outMchId: @salt, # 查询条件类型为1时必填
      }
    end
    private

    def get_mab(js)
      mab = []
      js.deep_symbolize_keys
      sign_js = {}
      js.each do |k, v|
        if v.present?
          sign_js[k] = v
        end
      end
      sign_js.keys.sort_by {|x| x.downcase}.each do |k|
        mab << "#{k}=#{js[k].to_s}" if ![:mac, :sign].include?(k.to_sym)
      end
      mab.join('&')
    end
    def get_mac(js, key)
      Digest::MD5.hexdigest(get_mab(js).to_s + key.to_s).upcase
    end

  end
end
