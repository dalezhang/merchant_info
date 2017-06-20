# frozen_string_literal: true

class Role < ApplicationRecord
  include Mongoid::Document
  # has_many :users, through: :users_role
  has_and_belongs_to_many :users
  field :name, type: String
  field :chinese_name, type: String
end
