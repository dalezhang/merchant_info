# frozen_string_literal: true

class Logs::ErrorLog < ApplicationRecord
  field :sender
  field :err_title
  field :err_message
  field :call_stack
end
