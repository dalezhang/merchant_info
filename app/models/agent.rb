# frozen_string_literal: true

class Agent < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Logging
  field :name, type: String
  field :level, type: Integer, default: 1
  field :parent_id, type: String
  field :d0_add_rate, type: Float, default: 0.0
  field :t1_add_rate, type: Float, default: 0.0
  field :partner_id, type: String # 代理商（公司）唯一标识
  validates :partner_id, presence: true, uniqueness: { case_sensitive: false, message: '该partne_id已经存在' }
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

  def children_users
    agent_ids = children.pluck(:id)
    agent_ids += [self.id]
    User.where(agent_id: agent_ids)
  end

  def parent
    Agent.find_by(id: self.parent_id)
  end

  def current_rate
    d0_init = Rails.application.secrets.pooul['d0_init_rate'].to_f
    t1_init = Rails.application.secrets.pooul['t1_init_rate'].to_f
    parent_d0_rate = d0_init + self.d0_add_rate
    parent_t1_rate = t1_init + self.t1_add_rate
    parent = self.parent_id.present? ? Agent.find_by(id: self.parent_id) : nil
    loop do
      if parent.present?
        parent_d0_rate += parent.d0_add_rate
        parent_t1_rate += parent.t1_add_rate
      else
        break
      end
      parent = parent.parent_id.present? ? Agent.find_by(id: parent.parent_id) : nil
    end
    {
      d0: parent_d0_rate,
      t1: parent_t1_rate
    }
  end

  def name_with_level
    "#{name} Lv#{level}"
  end

end
