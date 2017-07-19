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
  before_validation :generate_partner_id

  def find_level
    if parent_id.present? && Agent.find_by(id: parent_id)
      self.level = Agent.find(parent_id).level + 1
    else
      self.level = 1
    end
  end

  def generate_partner_id
    if self.new_record? && !self.partner_id.present?
      n =  Agent.count.to_s
      partner_id = "p#{sprintf('%07d', n)}"
      while Agent.find_by(partner_id: partner_id).present?
        n += 1
      end
      self.partner_id = "p#{sprintf('%07d', n)}"
    end
  end

  def children
    Agent.where(parent_id: self.id.to_s)
  end

  def children_users
    agent_ids = children.pluck(:id)
    agent_ids = agent_ids.map(&:to_s)
    User.in(agent_id: agent_ids)
    #User.where(agent_id: self.id.to_s)
  end

  def parent
    Agent.find_by(id: self.parent_id)
  end

  def current_rate
    d0_init = Rails.application.secrets.pooul['d0_init_rate'].to_f || 0
    t1_init = Rails.application.secrets.pooul['t1_init_rate'].to_f || 0
    parent_d0_rate = BigDecimal.new(d0_init.to_s) + BigDecimal.new(self.d0_add_rate.to_s || 0)
    parent_t1_rate = BigDecimal.new(t1_init.to_s) + BigDecimal.new(self.t1_add_rate.to_s || 0) 
    parent = self.parent_id.present? ? Agent.find_by(id: self.parent_id) : nil
    loop do
      if parent.present?
        parent_d0_rate += BigDecimal.new(parent.d0_add_rate.to_s)
        parent_t1_rate += BigDecimal.new(parent.t1_add_rate.to_s)
      else
        break
      end
      parent = parent.parent_id.present? ? Agent.find_by(id: parent.parent_id) : nil
    end
    {
      d0: parent_d0_rate.to_f,
      t1: parent_t1_rate.to_f
    }
  end

  def name_with_level
    "#{name} Lv#{level}"
  end

end
