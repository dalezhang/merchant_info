require "base64"
require 'digest/md5'

# http://docs.qiniuyun.com/api/form_api/
module QiniuyunHelper

  def qiniuyun_bucket
    Rails.application.secrets.qiniuyun['bucket']
  end

  def qiniuyun_bucket_key
    Rails.application.secrets.qiniuyun['bucket_key']
  end

  def qiniuyun_bucket_host
    Rails.application.secrets.qiniuyun['bucket_host']
  end

  def qiniuyun_form_url
    "#{Rails.application.secrets.qiniuyun['form_api_url']}/#{qiniuyun_bucket}"
  end

  def qiniuyun_policy_json options={}
    options[:prefix] ||= ""
    {
      "bucket" => qiniuyun_bucket,
      "save-key" => "#{options[:prefix]}/{filemd5}{.suffix}",
      "return-url" => "#{request.base_url}/__qiniuyun_uploaded",
      "expiration" => 30.minutes.since.to_i
    }
  end

  def qiniuyun_policy options={}
    Base64.encode64(qiniuyun_policy_json(options).to_json).gsub("\n", "")
  end

  def qiniuyun_signature options={}
    Digest::MD5.hexdigest [qiniuyun_policy(options), qiniuyun_bucket_key].join("&")
  end

  def qiniuyun_meta_tags options={}
    [
      tag(:meta, name: "qiniuyun-form-url", content: qiniuyun_form_url),
      tag(:meta, name: "qiniuyun-policy", content: qiniuyun_policy(options)),
      tag(:meta, name: "qiniuyun-signature", content: qiniuyun_signature(options)),
      tag(:meta, name: "qiniuyun-domain", content: qiniuyun_bucket_host)
    ].join("\n").html_safe
  end
end