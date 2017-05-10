# frozen_string_literal: true

class AdminController < ApplicationController
  include Authentication
  before_action :authenticate_user!
end
