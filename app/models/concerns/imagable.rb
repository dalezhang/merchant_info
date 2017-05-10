# frozen_string_literal: true

require 'active_support/concern'

module Imagable
  extend ActiveSupport::Concern

  def get_asset_img(key_word)
    @img = AssetImg.find_by(token: send("#{key_word}_token")) if send("#{key_word}_token")
    unless @img
      @img = AssetImg.new
      send("#{key_word}_token=", @img.generate_token)
    end
    @img
  end
end
