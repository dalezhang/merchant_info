# frozen_string_literal: true

require 'zip'
module Biz
  class ZxInfcApi < IntfcBase
    attr_accessor :merchant, :zx_request

    def initialize(mch, channel)
      if mch.class == Merchant
        @merchant = mch
      elsif merchant = Merchant.find(mch)
        @merchant = merchant
      else
        raise 'merchant 无效'
      end
      raise "channel should be one of ['wechat', 'alipay']" unless %w[wechat alipay].include?(channel)
      @channel = channel
      @zx_request = @merchant.request_and_response['zx_request'][@channel]
      raise "zx_request.#{@channel} 无内容，请先生成进件请求。\n#{@merchant.request_and_response['zx_request']}" unless @zx_request.present?
    end

    # appl_typ =>  新增：0；变更：1；停用：2
    def send_intfc(req_typ)
      raise '请先生成进件请求。' if @zx_request['chnl_mercht_id'].size < 11
      xml = nil
      case req_typ
      when '新增'
        xml = prepare_request('0')
      when '变更'
        xml = prepare_request('1')
      when '停用'
        xml = end_zx_queryrepare_request('2')
      when '查询'
        xml = prepare_query
        return send_zx_query(xml)
      when '创建appid'
        return create_appid
      when '查询appid'
        return query_appid
      else
        return log_error @merchant, '请求', '未知的请求类型'
      end
      if send_zx_intfc(xml, req_typ)
        return "返回信息已保存在request_and_response.zx_response.#{@channel}_#{req_typ}"
      end
      false
    end

    private

    def sign(mabs)
      @mab = mabs.join.encode('GBK', 'UTF-8')
      key = OpenSSL::PKey::RSA.new(File.read("#{Rails.application.secrets.pooul['keys_path']}/zx_prod_key.pem"))
      crt = OpenSSL::X509::Certificate.new(File.read("#{Rails.application.secrets.pooul['keys_path']}/zx_prod.crt"))
      sign = OpenSSL::PKCS7.sign(crt, key, @mab, [], OpenSSL::PKCS7::DETACHED)
      sign.certificates = []
      Base64.strict_encode64 sign.to_der
    end

    # appl_typ =>  新增：0；变更：1；停用：2
    def prepare_request(appl_typ)
      mabs = []
      missed_require_fields = []
      raise '请先上传营业执照' unless get_lics_file # 获取营业执照
      trancode = '0100SDC1'
      # appl_typ = 0 #新增：0；变更：1；停用：2

      builder = Nokogiri::XML::Builder.new(encoding: 'GBK') do |xml|
        xml.ROOT do
          CSV.foreach("#{Rails.root}/db/init_data/zx_reg_fields.csv", headers: true) do |r|
            val = r['f_name'] ? eval(r['f_name']) : @zx_request[r['regn_en_nm'].downcase]
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

    def send_zx_intfc(data, req_typ)
      return unless !has_error && data
      url = Rails.application.secrets.biz['zx']['infc_url']
      ret = post_xml_gbk('zx_intfc', url, data)
      resp_hash = Hash.from_xml(ret)
      if resp_hash.present?
        log_js = {
            model: 'Biz::ZxInfcApi',
            method: 'send_zx_intfc',
            merchant: @merchant.id.to_s,
            request_hash: data.to_s, 
            response_hash: resp_hash.to_s,
        }
        log_es(log_js)
        resp_hash['ROOT']['Msg_Sign'] = '**'
        @merchant.request_and_response.zx_response["#{@channel}_#{req_typ}"] = resp_hash
        @merchant.save
        unless resp_hash['ROOT']['rtncode'] == '00000000'
          return log_error @merchant, resp_hash['ROOT']['rtninfo']
        end
      else
        return log_error @merchant, '无返回信息'
      end
      true
    end

    def prepare_query
      case @channel
      when 'wechat'
        chnl_mercht_id = "zx_wechat_#{@merchant.merchant_id}"
        pay_chnl_encd =  '0002'
      when 'alipay'
        chnl_mercht_id = "zx_alipay_#{@merchant.merchant_id}"
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
      js = Hash.from_xml data
      js['ROOT']['Msg_Sign'] = '**'
      @merchant.request_and_response.zx_request["#{@channel}_query"] = js
      url = 'https://219.142.124.205:30280'
      ret = post_xml_gbk('zx_intfc_query', url, data)
      resp_hash = Hash.from_xml ret
      if resp_hash.present?
        resp_hash['ROOT']['Msg_Sign'] = '**'
        @merchant.request_and_response.zx_response["#{@channel}_query"] = resp_hash
        @merchant.save
        unless resp_hash['ROOT']['Chnl_Id'] == '10000022'
          return log_error @merchant, resp_hash['ROOT']['rtninfo']
        end
      else
        return log_error @merchant, '查询', '无返回信息'
      end
      log_js = {
          model: 'Biz::ZxInfcApi',
          method: 'send_zx_query',
          merchant: @merchant.id.to_s,
          request_hash: data.to_s, 
          response_hash: resp_hash.to_s,
      }
      log_es(log_js)
      "返回信息已保存在request_and_response -> zx_response -> #{@channel}_query"
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

    def create_appid
      url = 'https://api.mch.weixin.qq.com/secapi/mch/addsubdevconfig'
      key = '7H5sFkI3cJ32yD9bV6G224gH5hAZPgZK'
      sub_mch_id = @merchant.request_and_response.zx_response["#{@channel}_query"]["ROOT"]["Mercht_Idtfy_Num"] rescue ''
      raise "sub_mch_id 为空，请检查zx_response[#{@channel}_query][ROOT][Mercht_Idtfy_Num]" unless sub_mch_id.present?
      js = {}
      {
        appid: Rails.application.secrets.biz['zx']['appid'], # 微信分配的公众账号 ID
        mch_id: Rails.application.secrets.biz['zx']['mch_id'], # 商户号
        sub_mch_id: sub_mch_id, #子商户号
      }.map {|k,v| js[k] = v if v.present? }
      if @merchant.jsapi_path.present?
        js[:jsapi_path] = @merchant.jsapi_path # JSAPI支付授权目录
      elsif @merchant.appid.present?
        js[:sub_appid] = @merchant.sub_appid # 微信公众号
      elsif @merchant.subscribe_appid.present?
        js[:subscribe_appid] =  @merchant.subscribe_appid # 户推荐关注公众账号APPID
      else
        raise "jsapi_path,sub_appid,subscribe_appid必须有一个不为空"
      end
      js[:sign] = Biz::Md5Sign.get_mac js, key
      xml = js.to_xml(root: 'xml', skip_instruct: true, dasherize: false)
      @request = xml
      @response = Biz::WechatCert.post(url, body: xml, verify: false)
      log_js = {
        model: 'Biz::ZxInfcApi',
        method: 'create_appid_info',
        merchant: @merchant.id.to_s,
        request_hash: @request.to_s,
        response_hash: @response.to_s,
      }
      log_es(log_js)
      @merchant.request_and_response['zx_request']['appid_create'] = @response.to_hash
      @merchant.save
      "返回信息已保存在request_and_response -> zx_response -> appid_create"
    end

    def query_appid
      url = 'https://api.mch.weixin.qq.com/secapi/mch/addsubdevconfig'
      key = '7H5sFkI3cJ32yD9bV6G224gH5hAZPgZK'
      sub_mch_id = @merchant.request_and_response.zx_response["#{@channel}_query"]["ROOT"]["Mercht_Idtfy_Num"] rescue ''
      raise "sub_mch_id 为空，请检查zx_response[#{@channel}_query][ROOT][Mercht_Idtfy_Num]" unless sub_mch_id.present?
      js = {}
      {
        appid: Rails.application.secrets.biz['zx']['appid'], # 微信分配的公众账号 ID
        mch_id: Rails.application.secrets.biz['zx']['mch_id'], # 商户号
        sub_mch_id: sub_mch_id, #子商户号
      }.map {|k,v| js[k] = v if v.present? }
      js[:sign] = Biz::Md5Sign.get_mac js, key
      xml = js.to_xml(root: 'xml', skip_instruct: true, dasherize: false)
      @request = xml
      @response = Biz::WechatCert.post(url, body: xml, verify: false)
      log_js = {
        model: 'Biz::ZxInfcApi',
        method: 'query_appid_info',
        merchant: @merchant.id.to_s,
        request_hash: @request.to_s,
        response_hash: @response.to_s,
      }
      log_es(log_js)
      @merchant.request_and_response['zx_request']['appid_query'] = @response.to_hash
      @merchant.save
      "返回信息已保存在request_and_response -> zx_response -> appid_query"
    end
  end
end
