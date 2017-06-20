
# frozen_string_literal: true

module Logging
  extend ActiveSupport::Concern
  attr_accessor :has_error, :messages, :error_message

  def log_error(*args)
    @sender, @title, @message, @call_stack, @params = *args
    @has_error = true
    @call_stack = caller(2)[0..2].join("\n") unless @call_stack
    params_hash = JSON.parse @params.to_json if @params

    if ErrorLog.class == Class
      ErrorLog.create(
        sender: @sender, err_title: @title, err_message: @message, params: params_hash ,
        call_stack: @call_stack
      )
    end
    false
  end

  def error_message
    "#{@title}#{@message.present? ? (': ' + @message) : '.'}"
  end
end
