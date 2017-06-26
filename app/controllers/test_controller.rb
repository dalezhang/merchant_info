# frozen_string_literal: true

class TestController < AdminController
  def wechat_cert

    if params[:commit] == '创建'
      url = 'https://api.mch.weixin.qq.com/secapi/mch/addsubdevconfig'
      js = {
        appid: params[:item][:appid], # 微信分配的公众账号 ID
        mch_id: params[:item][:mch_id], # 商户号
        sub_mch_id: params[:item][:sub_mcn_id], #子商户号
        jsapi_path:  params[:item][:jsapi_path], # 子商户公众账号 JSAPI 支付授权目录子商户
        sub_appid: params[:item][:sub_appid], # 子商户SubAPPID
        subscribe_appid: params[:item][:subscribe_appid], # 微信分配的服务商公众号或 APP 账号 ID；如为空，则值传NULL（字母大写小写均可）
      }
      xml = js.to_xml(root: 'xml', skip_instruct: true, dasherize: false)
      @response = Biz::WechatCert.post(url, body: xml, verify: false)
    elsif params[:commit] == '查询'
      url = 'https://api.mch.weixin.qq.com/secapi/mch/querysubdevconfig'
      js = {
        appid: params[:item][:appid], # 微信分配的公众账号 ID
        mch_id: params[:item][:mch_id], # 商户号
        sub_mch_id: params[:item][:sub_mcn_id], #子商户号
      }
      xml = js.to_xml(root: 'xml', skip_instruct: true, dasherize: false)
      @response = Biz::WechatCert.post(url, body: xml, verify: false)
    end
    redirect_to action: :zx_appid, response: @response.to_s
  end
end
