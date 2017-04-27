module Authentication
  extend ActiveSupport::Concern

  def authenticate_user!
  	if current_user
  		return true
  	else
  		redirect_to new_users_session_path
  	end
  end

  def current_user
  	User.find_by(id: session[:user_id].to_s)
  end


  def logout
    session.clear
    redirect_to :action => 'login'
  end
end