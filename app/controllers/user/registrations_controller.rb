# frozen_string_literal: true

class User::RegistrationsController < AdminController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    redirect_to root_path
    # super
  end

  # POST /resource
  def create
    redirect_to root_path
    # super
  end

  # GET /resource/edit
  def edit
    @user = current_user
  end

  # PUT /resource
  def update
    if current_user && current_user.verify!(params[:user][:current_password])
      current_user.update(user_params)
      session[:user_id] = current_user.id.to_s
      flash[:success] = '信息修改成功。'
    else
      params[:user][:password].clear
      flash[:error] = '请输入正确的密码。'
    end
    redirect_to action: :edit, id: current_user.id.to_s
  # rescue Exception => e
  #   flash[:error] = e.message
  #   redirect_to action: :edit, id: current_user.id.to_s
  end

  # DELETE /resource
  def destroy
    redirect_to root_path
    # super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  private
  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :tel, :name, :company_name
    )
  end
end
