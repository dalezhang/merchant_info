# frozen_string_literal: true

class ErrorLog < ApplicationRecord
  include Mongoid::Timestamps
  field :sender, type: String
  field :err_title, type: String
  field :err_message, type: String
  field :call_stack
end
