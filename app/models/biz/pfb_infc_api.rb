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
      raise "channel should be one of ['wechat', 'alipay']" unless %w[wechat alipay].include?(channel)
      @channel = channel
      @pfb_request = @merchant.request_and_response["pfb_request"][@channel]
      raise "zx_request 无内容，请先生成进件请求" unless @pfb_request.present?
    end



    def get_mab(js)
      mab = []
      js.keys.sort.each do |k|
        mab << "#{k}=#{js[k].to_s}" if k != :mac && k != :sign && js[k]
      end
      mab.join('&')
    end
    def get_mac(js, key)
      Digest::MD5.hexdigest(get_mab(js).to_s + key.to_s).upcase
    end
  end
end

