# frozen_string_literal: true

class Location < ApplicationRecord
  include Mongoid::Document
  field :chinese_sort_name, type: String
  field :location_code, type: String
  field :location_name, type: String
  field :pub_location_code, type: String
end
