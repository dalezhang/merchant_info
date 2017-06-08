module I18n
  class MissingTranslation
    module Base
      def message
        keys[1..-1].join('.')
      end
    end
  end
end