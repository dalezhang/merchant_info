class User::SessionsController < ApplicationController
# before_action :configure_sign_in_params, only: [:create]
  include Authentication
  layout 'login'
  # GET /resource/sign_in
  def new
    @user = User.new
  end

  # POST /resource/sign_in
  def create
    if request.post?
      @user = User.find_by(email: params[:user][:email])
      if @user && @user.verify!(params[:user][:password])
        session[:user_id] = @user.id.to_s
        redirect_to root_path
      else
        params[:user][:password].clear
        flash[:error] = '请输入正确的用户名和密码。'
        redirect_to action: :new
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  def self.resource_name
    'user'
  end
  def resource_name
    'user'
  end
end
