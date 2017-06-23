# frozen_string_literal: true

class TestController < ResourcesController
	def wechat_cert
		if params[:step] == ''
		url = 'https://api.mch.weixin.qq.com/secapi/mch/addsubdevconfig'
		js = {
			appid: 'wxac068111ed63b536', # 微信分配的公众账号 ID
			mch_id: '1400528202', # 商户号
			sub_mch_id: '20170106', #子商户号
			jsapi_path: 'http://www.qq.com/wechat/', # 子商户公众账号 JSAPI 支付授权目录子商户
			sub_appid: 'wx931386123456789e', # 子商户SubAPPID
			subscribe_appid: '', # 微信分配的服务商公众号或 APP 账号 ID；如为空，则值传NULL（字母大写小写均可）
		}
		xml = js.to_xml(root: 'xml', skip_instruct: true, dasherize: false)
		Biz::WechatCert.post(url, body: xml, verify: false)
	end
end