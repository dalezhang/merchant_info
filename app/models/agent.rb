# frozen_string_literal: true

class Agent < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Logging
  field :name, type: String
  field :level, type: Integer, default: 0
  field :parent_id
  field :share_rate, type: Integer, default: 100
  field :partner_id, type: String # 代理商（公司）唯一标识
  has_many :children, class_name: 'Agent', foreign_key: 'parent_id', dependent: :destroy
  has_many :users



end
