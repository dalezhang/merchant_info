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
      raise "channel should be one of ['wechat', 'alipay']" unless %w[wechat alipay].include?(channel)
      @channel = channel
      @pfb_request = @merchant.request_and_response['pfb_request'][@channel]
      raise 'zx_request 无内容，请先生成进件请求' unless @pfb_request.present?
    end

    def upload_relate_pictures
      [
        @merchant.legal_person.identity_card_front_key,# 身份证正面
        @merchant.legal_person.identity_card_back_key, # 身份证反面
        @merchant.legal_person.id_with_hand_key, # 手持身份证
        @merchant.bank_info.right_bank_card_key, # 银行卡正面
        @merchant.company.license_key, # 营业执照
        @merchant.company.shop_picture_key, # 门面照
        @merchant.company.pfb_account_licence_key, # 农商行，开户许可证
      ].each do |key|
        if key.present?
          upload_picture(key)
        end
      end
    end

    def upload_picture(key)
      raise "merchant_id 不能为空" unless @merchant.merchant_id.present?
      raise "bucket_url 不能为空" unless @merchant.user.bucket_url.present?
      ftp = Net::FTP.new('60.205.203.64', 'A147920196116310531', 'A]ke7))}W=O-76,9?i')
      ftp.chdir("/#{@merchant.merchant_id}/#{key}")
      ftp.putbinaryfile("#{@merchant.user.bucket_url}/#{key}")
      ftp.close
    end

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
