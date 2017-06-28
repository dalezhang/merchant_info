# Loads action_mailer settings from email.yml
# and turns deliveries on if configuration file is found

# 加上面这句，是因为gmail需要ssl方式来登录，ruby的lib中Net:SMTP TLS不支持，那么需要修改一下
# require "smtp_tls"
require 'mail'

# filename = File.join(File.dirname(__FILE__), '..', 'email.yml')

filename = File.join(Rails.root, 'config', 'email.yml')
if File.file?(filename)
  mailconfig = YAML.load_file(filename)

  if mailconfig.is_a?(Hash) && mailconfig.key?(Rails.env)
    ActionMailer::Base.perform_deliveries = true
    mailconfig[Rails.env].each do |k, v|
      v.symbolize_keys! if v.respond_to?(:symbolize_keys!)
      ActionMailer::Base.send("#{k}=", v)
    end
  end
end
ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.default_url_options = {
#   host: Rails.application.secrets.mail['url_host']
# }
ActionMailer::Base.smtp_settings = {
  address:        Rails.application.secrets.smtp_settings['address'],
  port:           Rails.application.secrets.smtp_settings['port'],
  authentication: Rails.application.secrets.smtp_settings['authentication'],
  user_name:      Rails.application.secrets.smtp_settings['user_name'],
  password:       Rails.application.secrets.smtp_settings['password'],
  # domain:         Rails.application.secrets.smtp_settings['domain'],
  enable_starttls_auto: Rails.application.secrets.smtp_settings['enable_starttls_auto'],
}
