# frozen_string_literal: true

class User::PasswordController < ApplicationController
  layout 'login'
  def send_reset_email
    @user = User.find_by(email: params[:user][:email])
    @user.generate_reset_token
    flash[:success] = "邮件已发送，请查收。"
    redirect_to new_user_session_path
  rescue Exception => e
    flash[:error] = e.message
    log_error @user, e.message, '', e.backtrace, params
    redirect_to new_user_session_path
  end

  def edit
    @user = User.find_by(reset_token: params[:reset_token])
    if !@user.present?
      flash[:error] = "reset_token无效。"
      redirect_to new_user_session_path
      return
    elsif @user.expired_at < Time.zone.now
      flash[:error] = "reset_token已过期。"
      redirect_to new_user_session_path
      return
    end
    @user.current_email = @user.email
  end

  def update
    @user = User.find_by(reset_token: params[:reset_token])
    if !@user.present?
      flash[:error] = "无效的重置token。"
    elsif @user.expired_at < Time.zone.now
      flash[:error] = "token已过期，请重新申请重置密码。"
    else
      @user.update(user_params.merge({reset_token: nil}))
      flash[:success] = "密码修改成功"
    end
    redirect_to new_user_session_path
  rescue Exception => e
    flash[:error] = e.message
    log_error @user, e.message, '', e.backtrace, params
    redirect_to new_user_session_path
  end


  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :tel, :name, :company_name
    )
  end
end
