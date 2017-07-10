# frozen_string_literal: true

class Agent < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Logging
  field :name, type: String
  field :level, type: Integer, default: 1
  field :parent_id
  field :share_rate, type: Integer, default: 100
  field :partner_id, type: String # 代理商（公司）唯一标识
  has_many :users

  before_save :find_level

  def find_level
    if parent_id.present?
      self.level = Agent.find(parent_id).level + 1
    else
      self.level = 1
    end
  end

  def children
    Agent.where(parent_id: self.id.to_s)
  end



end
