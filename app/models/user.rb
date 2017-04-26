class User < ApplicationRecord
	include Mongoid::Document
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	# devise :database_authenticatable, :registerable, :lockable,
	#        :recoverable, :rememberable, :trackable, :validatable
	field :email, type: String
    field :encrypted_password, type: String
    field :sale, type: String
    field :last_signed_in, type: Time
    field :created_at, type: Time, default: ->{ Time.now }



	has_and_belongs_to_many :role
	has_many :merchants
end
