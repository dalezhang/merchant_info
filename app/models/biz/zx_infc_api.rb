# frozen_string_literal: true

require 'zip'
module Biz
  class ZxInfcApi < IntfcBase
    attr_accessor :merchant, :zx_request

    def initialize(mch_id, channel)
      @has_error = false
      @messages = []
      if mch_id.class == Merchant
        @merchant = mch_id
      elsif merchant = Merchant.find_by(merchant_id: mch_id)
        @merchant = merchant
      else
        raise 'merchant_id 无效'
      end
      raise "channel should be one of ['wechat', 'alipay']" unless %w[wechat alipay].include?(channel)
      @channel = channel
      @zx_request = @merchant.request_and_response["zx_request"][@channel]
      raise "zx_request 无内容，请先生产进件请求" unless @zx_request.present?
    end

    # appl_typ =>  新增：0；变更：1；停用：2
    def send_intfc(appl_typ)
      xml = prepare_request(appl_typ)
      send_zx_intfc(xml)
    end

    def send_query
      xml = prepare_query
      request_hash = Hash.from_xml xml
      request_hash['ROOT'].delete('Msg_Sign')
      @merchant.request_and_response.zx_request["#{@channel}_query"] = request_hash
      @merchant.save
      send_zx_query(xml)
    end

    private

    def sign(mabs)
      @mab = mabs.join().encode('GBK', 'UTF-8')
      key = OpenSSL::PKey::RSA.new(File.read("#{Rails.application.secrets.pooul['keys_path']}/zx_prod_key.pem"))
      crt = OpenSSL::X509::Certificate.new(File.read("#{Rails.application.secrets.pooul['keys_path']}/zx_prod.crt"))
      sign = OpenSSL::PKCS7.sign(crt, key, @mab, [], OpenSSL::PKCS7::DETACHED)
      sign.certificates = []
      Base64.strict_encode64 sign.to_der
    end

    # appl_typ =>  新增：0；变更：1；停用：2
    def prepare_request(appl_typ)
      # bank_account = @zx_request.bank_account
      # return log_error(nil, "bank_account不能为空") unless bank_account
      mabs = []
      missed_require_fields = []
      raise '请先上传营业执照' unless get_lics_file # 获取营业执照
      trancode = '0100SDC1'
      # appl_typ = 0 #新增：0；变更：1；停用：2

      builder = Nokogiri::XML::Builder.new(encoding: 'GBK') do |xml|
        xml.ROOT do
          CSV.foreach("#{Rails.root}/db/init_data/zx_reg_fields.csv", headers: true) do |r|
            val = r['f_name'] ? eval(r['f_name']) : @zx_request[ r['regn_en_nm'].downcase ]
            unless val == 'NO_VALUE'
              xml.send r['regn_en_nm'], val
              if val
                mabs << val if r['is_sign_regn'] == '1'
              else
                missed_require_fields << "#{r['regn_en_nm']}(#{r['regn_cn_nm']})" if r['regn_nt_null'] == '1'
              end
            end
          end
          xml.Msg_Sign sign(mabs)
        end
      end

      if missed_require_fields.empty?
        builder.to_xml
      else
        raise "缺少必须的字段：\n" + missed_require_fields.join("\n")
      end
    end

    def get_lics_file # 获取营业执照
      return false unless @merchant.company.license_key.present?
      web_contents = open(@zx_request['lics_file_url'], &:read)
      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry(@merchant.company.license_key)
        zio.write web_contents
      end
      lics_file = stringio.string
      @lics_md5 = Digest::MD5.hexdigest(lics_file)
      @lics_file = Base64.encode64(lics_file)
      true
    end

    def send_zx_intfc(data)
      return unless !has_error && data
      url = 'https://219.142.124.205:30280'
      ret = post_xml_gbk('zx_intfc', url, data)
      return if has_error

      xml = Nokogiri::XML(ret)
      if xml.xpath('//rtncode').text == '00000000'
        @merchant.update!(status: 1)
      else
        raise xml.xpath('//rtninfo').text
      end
    end

    def prepare_query
      case @channel
      when 'wechat'
        chnl_mercht_id = @merchant.channel_data['zx_wechat_chnl_mercht_id']
        pay_chnl_encd =  '0002'
      when 'alipay'
        chnl_mercht_id = @merchant.channel_data['zx_alipay_chnl_mercht_id']
        pay_chnl_encd =  '0001'
      end

      mab_query = []
      mab_query << @zx_request[:chnl_id]
      mab_query << chnl_mercht_id
      mab_query << @zx_request[:pay_chnl_encd]
      mab_query << '0100SDC0'
      builder = Nokogiri::XML::Builder.new(encoding: 'GBK') do |xml|
        xml.ROOT do
          xml.Chnl_Id @zx_request[:chnl_id]
          xml.Chnl_Mercht_Id chnl_mercht_id
          xml.Pay_Chnl_Encd pay_chnl_encd
          xml.trancode '0100SDC0'
          xml.Msg_Sign sign(mab_query)
        end
      end
      builder.to_xml
    end

    def send_zx_query(data)
      url = 'https://219.142.124.205:30280'
      ret = post_xml_gbk('zx_intfc_query', url, data)
      resp_hash = Hash.from_xml ret
      if resp_hash['Chnl_Id'] == '10000022'
        # @merchant.mch_id = xml.xpath("//Mercht_Idtfy_Num").text
        # @merchant.status = 1 if @merchant.status < 1
        # if @merchant.changed?
        #   if @sent_post
        #     @sent_post.result_message = @merchant.changes.to_s
        #     @sent_post.save
        #   end
        #   @merchant.save
        # end
      else
        raise "返回记录没有对应资料,\n#{resp_hash['rtninfo']}"
      end
      resp_hash
    end

    def post_xml_gbk(_method, url, data)
      begin
        resp = HTTParty.post(url, body: data, headers: { "Content-Type": 'text/xml' }, verify: false)
      rescue => e
        raise "HTTP错误: #{e.message}"
      end
      ret = nil
      if resp.success?
        ret = resp.body
      else
        raise '中信服务器错误:' + resp.inspect
      end
      ret
    end

    def contr_info_list(xml, mabs)
      xml.Contr_Info_List do
        @zx_request['zx_contr_info_lists'].each do |cl|
          xml.Contrinfo do
            xml.Pay_Typ_Encd cl['pay_typ_encd']
            xml.Start_Dt cl['start_dt']
            xml.Pay_Typ_Fee_Rate cl['pay_typ_fee_rate']
          end
          mabs << cl['pay_typ_encd']
          mabs << cl['start_dt']
          mabs << cl['pay_typ_fee_rate']
        end
      end
      'NO_VALUE'
    end
  end
end
