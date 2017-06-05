
# frozen_string_literal: true

module Logging
  extend ActiveSupport::Concern
  attr_accessor :has_error, :messages, :error_message

  def log_error(*args)
    @sender, @title, @message, @call_stack = *args
    @has_error = true
    @call_stack = caller(2)[0..2].join("\n") unless @call_stack
    if defined?(ErrorLog)
      ErrorLog.create(
        sender: @sender, err_title: @title, err_message: @message,
        call_stack: @call_stack
      )
    end
    false
  end

  def error_message
    "#{@title}#{@message.present? ? (': ' + @message) : '.'}"
  end
end
