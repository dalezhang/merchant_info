module Biz
  class IntfcBase
    attr_accessor :has_error, :messages, :txt_request, :txt_response

    def send_intfc(bank_mct)
    end

    def query(bank_mct)
    end

    def log_error(*args)
      sender, title, message, call_stack = *args
      call_stack = caller(2)[0..2].join("\n") unless call_stack
      Logs::ErrorLog.create(
        sender: sender, err_title: title, err_message: message,
        call_stack: call_stack
      ) if defined?(Logs::ErrorLog)
      false
    end

  end
end