# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  def authenticate_user!
    if current_user
      true
    else
      redirect_to controller: 'user/sessions', action: :new
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id].to_s)
  end

  def logout
    session.clear
    redirect_to controller: 'user/sessions', action: :new
  end
end
