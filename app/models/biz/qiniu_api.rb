require 'qiniu'
module Biz
  module QiniuApi
    extend self

    def generate_token

      # 构建鉴权对象
      Qiniu.establish_connection! access_key: Rails.application.secrets.qiniuyun['qiniu_access_key'],
        secret_key: Rails.application.secrets.qiniuyun['qiniu_secret_key']
      # 要上传的空间
      bucket = "merchant-info"
      # 上传到七牛后保存的文件名
      key = nil
      # 构建上传策略，上传策略的更多参数请参照 http://developer.qiniu.com/article/developer/security/put-policy.html
      put_policy = Qiniu::Auth::PutPolicy.new(
        bucket, # 存储空间
        key,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
        3600    # token 过期时间，默认为 3600 秒，即 1 小时
      )
      # 构建回调策略，这里上传文件到七牛后， 七牛将文件名和文件大小回调给业务服务器.
      #callback_url = ''
      #callback_body = 'filename=$(fname)&filesize=$(fsize)' # 魔法变量的使用请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#magicvar
      #put_policy.callback_url= callback_url
      #put_policy.callback_body= callback_body
      # 生成上传 Token
      uptoken = Qiniu::Auth.generate_uptoken(put_policy)
      return uptoken
    end
  end
end
