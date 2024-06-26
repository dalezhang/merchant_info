# frozen_string_literal: true

class AssetImg < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  mount_uploader :avatar, ImageUploader # 图片
  field :token # 唯一识别码
  before_create :generate_token
  def generate_token
    self.token = UUID.new.generate unless token
  end
end
