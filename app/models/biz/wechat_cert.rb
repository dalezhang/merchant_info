class Biz::WechatCert
  include HTTParty
  file_path = "#{Rails.application.secrets.pooul['keys_path']}/merchant_info_wechat_appid_cert/apiclient_cert.p12"
  p12_contents = File.read(file_path)
  password = Rails.application.secrets.pooul['pkcs12_password']
  pkcs12 p12_contents, password
end