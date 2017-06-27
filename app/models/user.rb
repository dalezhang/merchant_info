# frozen_string_literal: true

class User < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  attr_accessor :password, :password_confirmation, :current_email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable, :lockable,
  #        :recoverable, :rememberable, :trackable, :validatable
  field :name, type: String
  field :email, type: String
  field :encrypted_password, type: String
  field :salt, type: String
  field :last_signed_in, type: Time
  field :token, type: String
  field :reset_token, type: String
  field :expired_at, type: Time
  field :bucket_url, type: String
  field :bucket_name, type: String
  field :company_name, type: String
  field :tel, type: String
  field :partner_id, type: String # 代理商（公司）唯一标识
  validates :email, format: { with: /^[\d,a-z]([\w\.\-]+)@([a-z0-9\-]+).([a-z\.]+[a-z])$/i, multiline: true, message: '邮箱地址格式不正确' }
  validates :email, presence: true, uniqueness: { case_sensitive: false, message: '该email已经存在' }
  validates :partner_id, presence: true

  has_and_belongs_to_many :roles

  before_save :generate_password, :generate_token
  before_update :check_if_modified_sensitive_values

  def merchants
    if self.roles.pluck(:name).include?('agent')
      user_ids = User.where(partner_id: self.partner_id).pluck(:id)
      Merchant.in(user_id: user_ids.map(&:to_s) )
    else
      Merchant.where(user_id: self.id.to_s )
    end
  end

  def children
    if self.roles.pluck(:name).include?('agent')
      user_ids = User.where(partner_id: self.partner_id.to_s).pluck(:id)
      user_ids.delete self.id
      User.in(_id: user_ids )
    else
      []
    end
  end

  def check_if_modified_sensitive_values
    # sensitive_values = ['partner_id']
    # if (sensitive_values & self.changes.keys).present?
    #   raise "#{sensitive_values.join(',')}不允许修改"
    # end
  end

  def verify!(password)
    cryt_func(salt, password).eql?(encrypted_password)
  end

  # 加密密码的算法
  def cryt_func(salt, password)
    Digest::SHA2.hexdigest("#{salt}+++#{password}")
  end

  # 生成用户密码
  def generate_password
    if password.present? && password_confirmation.present?
      raise '两次输入密码不一致！' unless password == password_confirmation
      raise '密码不得小于6位' if password.size < 6
      self.salt = ('a'..'z').to_a.sample(20).join # 随机salt
      self.encrypted_password = cryt_func(salt, password)
    end
  end

  def generate_token
    self.token = UUID.new.generate unless token.present?
  end

  def generate_reset_token
    self.reset_token = UUID.new.generate
    self.expired_at = Time.zone.now + 2.days
    options = {id: self.id, reset_token: self.reset_token, current_email: self.email}.merge Rails.application.config.action_mailer.default_url_options
    path = Rails.application.routes.url_helpers.edit_user_password_url(options)
    # txt = "
    #   <html>
    #     <body>
    #       <table class=‘content’>
    #         <tr>
    #           <td class=‘gray-font’>
    #             <p class=‘bold-font’ style=‘font-size: 20px’>
    #               #{self.email}的使用者，你好!
    #             </p>
    #             <p>
    #               我们刚刚收到了你要求重置密码的请求，请点击下方按钮开始重置密码。
    #             </p>
    #             <p>
    #               普尔云进件系统邀请你重置密码（如果你不需要重置密码，请忽略本邮件）
    #             </p>
    #           </td>
    #           <td class=‘expander’>
    #             有效期至#{self.expired_at.strftime("%Y-%m-%d %H:%m:%S")}
    #           </td>
    #         </tr>
    #       </table>
    #       <div class=’text-center‘>
    #         <a href=#{path} class ='btn btn-success btn-large' target='_blank'>
    #          重置密码
    #         </a>
    #       </div>
    #     </body>
    #   </html>
    # "
    txt = "
      #{self.email}的使用者，你好!
      我们刚刚收到了你要求重置密码的请求，请点击#{path}开始重置密码。（如果你不需要重置密码，请忽略本邮件）
      有效期至#{self.expired_at.strftime("%Y-%m-%d %H:%m:%S")}.
      "
    mail_api = Biz::MailerApi.new('普尔云进件系统-重置密码')
    mail_api.send(self.email, txt)
  end
end
