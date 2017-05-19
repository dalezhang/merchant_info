# frozen_string_literal: true

class User < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  attr_accessor :password, :password_confirmation
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
  field :bucket_url, type: String
  field :bucket_name, type: String
  validates :password, length: { minimum: 6 } if @password
  validates :email, :format=> {:with=> /^[\d,a-z]([\w\.\-]+)@([a-z0-9\-]+).([a-z\.]+[a-z])$/i, :multiline => true, :message=> "邮箱地址格式不正确"}
  validates :email,:presence => true, uniqueness: { case_sensitive: false, message: '该email已经存在' }

  has_and_belongs_to_many :roles
  has_many :merchants

  before_create :generate_password, :generate_token

  def verify!(password)
    cryt_func(salt, password).eql?(encrypted_password)
  end

  # 加密密码的算法
  def cryt_func(salt, password)
    Digest::SHA2.hexdigest("#{salt}+++#{password}")
  end

  # 生成用户密码
  def generate_password
    if @password && @password_confirmation
      if @password == @password_confirmation
        self.salt = ('a'..'z').to_a.sample(20).join # 随机salt
        self.encrypted_password = cryt_func(salt, password)
      else
        raise '两次输入密码不一致！'
      end
    else
      raise '请填入密码和确认密码！'
    end
  end

  def generate_token
    self.token = UUID.new.generate unless token
  end
end
