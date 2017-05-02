require 'active_support/concern'

module Imagable
  extend ActiveSupport::Concern

  def get_asset_img(key_word)
    @img = AssetImg.find_by(token: self.send("#{key_word}_token") ) if self.send("#{key_word}_token")
    unless @img
      @img = AssetImg.new
      self.send("#{key_word}_token=", @img.generate_token)
    end
    @img
  end
end
