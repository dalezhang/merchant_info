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
  field :expired_at, type: Time
  field :bucket_url, type: String
  field :bucket_name, type: String
  field :company_name, type: String
  field :tel, type: String
  field :partner_id, type: String # 代理商（公司）唯一标识
  validates :email, format: { with: /^[\d,a-z]([\w\.\-]+)@([a-z0-9\-]+).([a-z\.]+[a-z])$/i, multiline: true, message: '邮箱地址格式不正确' }
  validates :email, presence: true, uniqueness: { case_sensitive: false, message: '该email已经存在' }

  has_and_belongs_to_many :roles
  has_many :merchants

  before_save :generate_password, :generate_token, :generate_partner_id
  before_create :generate_password, :generate_token, :generate_partner_id

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
  def generate_partner_id
    self.partner_id = UUID.new.generate unless partner_id.present?
  end
end
