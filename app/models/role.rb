class Role < ApplicationRecord
	include Mongoid::Document
  #has_many :users, through: :users_role
	has_and_belongs_to_many :users
  field :name, type: String
end
