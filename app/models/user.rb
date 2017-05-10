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
    end
  end

  def generate_token
    self.token = UUID.new.generate unless token
  end
end
