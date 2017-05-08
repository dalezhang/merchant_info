require 'zip'
module Biz
  class ZxInfcApi < IntfcBase

    attr_accessor :merchant, :zx_mct_info

    def initialize(mch_id)
      @has_error = false
      @messages = []
      if mch_id.class == Merchant
        @merchant = mch_id
      elsif merchant = Merchant.find_by(merchant_id: mch_id)
        @merchant = merchant
      else

        log_error(nil, 'Merchant require')
        raise 'Merchant require'

      end
      @zx_mct_info = Biz::ZxMctInfo.new(@merchant)

    end

    #appl_typ =>  新增：0；变更：1；停用：2
    def send_intfc(appl_typ)
      xml = prepare_request(appl_typ)
      send_zx_intfc(xml) unless @has_error
    end
    def send_query
      xml = prepare_query
      send_zx_query(xml)
    end


    private
    def sign(mabs)
      @mab = mabs.join().encode('GBK', 'UTF-8')
      key = OpenSSL::PKey::RSA.new(File.read("#{AppConfig.get('pooul', 'keys_path')}/zx_prod_key.pem"))
      crt = OpenSSL::X509::Certificate.new(File.read("#{AppConfig.get('pooul', 'keys_path')}/zx_prod.crt"))
      sign = OpenSSL::PKCS7::sign(crt, key, @mab, [], OpenSSL::PKCS7::DETACHED)
      sign.certificates = []
      Base64.strict_encode64 sign.to_der
    end

    #appl_typ =>  新增：0；变更：1；停用：2
    def prepare_request(appl_typ)
      bank_account = @zx_mct_info.bank_account
      return log_error(nil, "bank_account不能为空") unless bank_account
      mabs = []
      missed_require_fields = []

      lics = @zx_mct_info.lics
      return log_error(nil, "请先上传营业执照") unless lics
      lics_file = get_lics_file(lics) # 获取营业执照

      trancode = '0100SDC1'
      # appl_typ = 0 #新增：0；变更：1；停用：2

      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          CSV.foreach("#{Rails.root}/db/init_data/zx_reg_fields.csv", headers: true) do |r|
            val = r['f_name'] ? eval(r['f_name']) : @zx_mct_info.send(r['regn_en_nm'].downcase)
            unless val == "NO_VALUE"
              xml.send r['regn_en_nm'], val
              if val
                mabs << val if r['is_sign_regn'] == "1"
              else
                missed_require_fields << "#{r['regn_en_nm']}(#{r['regn_cn_nm']})" if r['regn_nt_null'] == "1"
              end
            end
          end
          xml.Msg_Sign sign(mabs)
        }
      end

      if missed_require_fields.empty?
        builder.to_xml
      else
        log_error(nil, "缺少必须的字段：\n" + missed_require_fields.join("\n"))
      end
    end

    def get_lics_file(lics) # 获取营业执照
      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry(lics.attach_asset_identifier)
        zio.write File.read("#{Rails.root}/public#{URI.decode(lics.attach_asset.url)}")
      end
      lics_file = stringio.string
      lics_md5 = Digest::MD5.hexdigest(lics_file)
      lics_file = Base64.encode64(lics_file)
      return lics_file
    end

    def send_zx_intfc(data)
      return unless !has_error && data
      url = 'https://219.142.124.205:30280'
      ret = post_xml_gbk('zx_intfc', url, data)
      return if has_error

      xml = Nokogiri::XML(ret)
      if xml.xpath("//rtncode").text == '00000000'
        @merchant.update!(status: 1)
      else
        log_error(nil, "返回中没有rtninfo:" + xml.xpath("//rtninfo").text)
      end
    end

    def prepare_query
      mab_query = []
      mab_query << @zx_mct_info.inspect[:chnl_id]
      mab_query << @zx_mct_info.inspect[:chnl_mercht_id]
      mab_query << @zx_mct_info.inspect[:pay_chnl_encd]
      mab_query << '0100SDC0'
      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          xml.Chnl_Id @zx_mct_info.inspect[:chnl_id]
          xml.Chnl_Mercht_Id @zx_mct_info.inspect[:chnl_mercht_id]
          xml.Pay_Chnl_Encd @zx_mct_info.inspect[:pay_chnl_encd]
          xml.trancode '0100SDC0'
          xml.Msg_Sign sign(mab_query)
        }
      end
      builder.to_xml
    end
    def send_zx_query(data)
      url = 'https://219.142.124.205:30280'
      ret = post_xml_gbk('zx_intfc_query', url, data)
      return if @has_error

      xml = Nokogiri::XML(ret)
      if xml.xpath("//Chnl_Id").text == '10000022'
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
        log_error(nil, "返回记录没有对应资料")
      end
    end

    def post_xml_gbk(method, url, data)
      begin
        resp = HTTParty.post(url, body: data, headers: {"Content-Type": 'text/xml'}, verify: false)
      rescue => e
        return log_error(nil, "HTTP错误: #{e.message}")
      end
      ret = nil
      if resp.success?
        ret = resp.body
      else
        log_error(nil, "中信服务器错误:" + resp.inspect)
      end
      ret
    end
    def contr_info_list(xml, mabs)
      xml.Contr_Info_List {
        @zx_mct.zx_contr_info_lists.each do |cl|
          xml.Contrinfo {
            xml.Pay_Typ_Encd cl.pay_typ_encd
            xml.Pay_Typ_Fee_Rate cl.pay_typ_fee_rate
            xml.Start_Dt cl.start_dt
          }
          mabs << cl.pay_typ_encd
          mabs << cl.start_dt
          mabs << cl.pay_typ_fee_rate
        end
      }
      "NO_VALUE"
    end
  end
end
