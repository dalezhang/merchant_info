# frozen_string_literal: true

class User < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Logging

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
  field :agent_id
  validates :email, format: { with: /^[\d,a-z]([\w\.\-]+)@([a-z0-9\-]+).([a-z\.]+[a-z])$/i, multiline: true, message: '邮箱地址格式不正确' }
  validates :email, presence: true, uniqueness: { case_sensitive: false, message: '该email已经存在' }
  validates :partner_id, presence: {message: 'partner_id 不能为空'}

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

  def agent
    Agent.find_by(id: agent_id)
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
    if self.save
      UserMailer.send(:reset_password_instructions, self.email).deliver
    end
  end

  def has_agent_role?
    return roles.pluck(:name).include?('agent')
  end
end
