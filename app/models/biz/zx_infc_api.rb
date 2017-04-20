require 'zip'
module Biz
  class ZxIntfcApi < IntfcBase
    def send_intfc(zx_mct,appl_typ)
      set_mct(zx_mct)
      xml = prepare_request(appl_typ)
      send_zx_intfc(xml) unless @has_error
    end
    def send_query(zx_mct)
      set_mct(zx_mct)
      xml = prepare_query
      send_zx_query(xml)
    end

    def confirmation(dt, chl_code, chl_id)
      trancode = '0200SDC5'
      mab_query = []
      mab_query << chl_id
      mab_query << chl_code
      mab_query << '1'
      mab_query << trancode
      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          xml.Chnl_Id chl_id
          xml.Pay_Chnl_Encd chl_code # 支付渠道编号,支付宝：0001；微信支付：0002
          xml.Clr_Dt dt # 清分日期
          xml.Clr_OK '1'
          xml.trancode trancode #交易代码
          xml.Msg_Sign sign(mab_query)
        }
      end
      url = Channel.find_by(channel_code: 'zx').clr_url
      post_xml_gbk('zxqf', url, builder.to_xml)
    end

    def download_dz_file(dt, chl_code, chl_id)
      trancode = '0100SDC4'

      mab_query = []
      mab_query << chl_id
      mab_query << chl_code
      mab_query << dt
      mab_query << trancode
      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          xml.Chnl_Id chl_id
          xml.Pay_Chnl_Encd chl_code # 支付渠道编号,支付宝：0001；微信支付：0002
          xml.Clr_Dt dt # 清分日期
          xml.trancode trancode #交易代码
          xml.Msg_Sign sign(mab_query)
        }
      end
      data = builder.to_xml
      url = Channel.find_by(channel_code: 'zx').clr_url
      ret = post_xml_gbk('zxdz', url, builder.to_xml)
      return unless ret
      hash = Hash.from_xml ret
      zip_str = hash["ROOT"]["Clr_Dtl"]
      if zip_str
        File.open("tmp/zx_#{chl_code}_#{dt}.zip",'wb') do |f|
          f.write Base64.decode64(zip_str)
        end
      end
    end

    private
    def set_mct(zx_mct)
      @zx_mct = zx_mct
      @sub_mct = zx_mct.sub_mct
      @org = @sub_mct.org
      @merchant = @org.merchant
      @has_error = false
      @messages = []
    end
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
      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry(lics.attach_asset_identifier)
        zio.write File.read("#{Rails.root}/public#{URI.decode(lics.attach_asset.url)}")
      end
      lics_file = stringio.string
      lics_md5 = Digest::MD5.hexdigest(lics_file)
      lics_file = Base64.encode64(lics_file)
      trancode = '0100SDC1'
      # appl_typ = 0 #新增：0；变更：1；停用：2

      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          CSV.foreach("#{Rails.root}/db/init_data/zx_reg_fields.csv", headers: true) do |r|
            val = r['f_name'] ? eval(r['f_name']) : @zx_mct_info[r['regn_en_nm'].downcase]
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

    def get_lics_file # 获取营业执照
      stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry(lics.attach_asset_identifier)
        zio.write File.read("#{Rails.root}/public#{URI.decode(lics.attach_asset.url)}")
      end
      lics_file = stringio.string
      lics_md5 = Digest::MD5.hexdigest(lics_file)
      lics_file = Base64.encode64(lics_file)
      return lics_file
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
    def send_zx_intfc(data)
      return unless !has_error && data
      url = Channel.find_by(channel_code: 'zx').clr_url
      ret = post_xml_gbk('zx_intfc', url, data)
      return if has_error

      xml = Nokogiri::XML(ret)
      if xml.xpath("//rtncode").text == '00000000'
        @org.zx_mct.status = 1
        @org.zx_mct.save!
      else
        log_error(nil, "返回中没有rtninfo:" + xml.xpath("//rtninfo").text)
      end
    end

    def prepare_query
      mab_query = []
      mab_query << @zx_mct.chnl_id
      mab_query << @zx_mct.chnl_mercht_id
      mab_query << @zx_mct.pay_chnl_encd
      mab_query << '0100SDC0'
      builder = Nokogiri::XML::Builder.new(:encoding => 'GBK') do |xml|
        xml.ROOT {
          xml.Chnl_Id @zx_mct.chnl_id
          xml.Chnl_Mercht_Id @zx_mct.chnl_mercht_id
          xml.Pay_Chnl_Encd @zx_mct.pay_chnl_encd
          xml.trancode '0100SDC0'
          xml.Msg_Sign sign(mab_query)
        }
      end
      builder.to_xml
    end
    def send_zx_query(data)
      url = Channel.find_by(channel_code: 'zx').clr_url
      ret = post_xml_gbk('zx_intfc_query', url, data)
      return if @has_error

      xml = Nokogiri::XML(ret)
      if xml.xpath("//Chnl_Id").text == '10000022'
        @sub_mct.mch_id = xml.xpath("//Mercht_Idtfy_Num").text
        @sub_mct.status = 1 if @sub_mct.status < 1
        if @sub_mct.changed?
          if @sent_post
            @sent_post.result_message = @sub_mct.changes.to_s
            @sent_post.save
          end
          @sub_mct.save
        end
      else
        log_error(nil, "返回记录没有对应资料")
      end
    end

    def post_xml_gbk(method, url, data)
      @txt_request = CommonTools.xml_del_tag data.encode('utf-8', 'gbk'), "Biz_Lics Msg_Sign"
      @web_log = Logs::WebLog.new(
        sender_name: method, sender: @zx_mct,
        sent_url: url, input_data: @txt_request
      )
      begin
        resp = HTTParty.post(url, body: data, headers: {"Content-Type": 'text/xml'}, verify: false)
      rescue => e
        @web_log.save
        return log_error(nil, "HTTP错误: #{e.message}")
      end
      ret = nil
      if resp.success?
        ret = resp.body
        @web_log.output_data = @txt_response = CommonTools.xml_del_tag ret.encode('utf-8', 'gbk'), "Msg_Sign"
      else
        log_error(nil, "中信服务器错误:" + resp.inspect)
      end
      @web_log.save!
      ret
    end
  end
end
