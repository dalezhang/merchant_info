# frozen_string_literal: true

class User::PasswordController < ApplicationController
  layout 'login'
  def send_reset_email
    @user = User.find_by(email: params[:user][:email])
    @user.generate_reset_token
    flash[:success] = "邮件已发送，请查收。"
    redirect_to new_user_session_path
  end

  def edit
    @user = User.find_by(email: params[:current_email])
    if !@user.present?
      flash[:error] = "无此用户。"
      redirect_to new_user_session_path
      return
    elsif @user.reset_token != params[:reset_token]
      flash[:error] = "reset_token无效。"
      redirect_to new_user_session_path
      return
    elsif @user.expired_at < Time.zone.now
      flash[:error] = "reset_token已过期。"
      redirect_to new_user_session_path
      return
    end
    @user.current_email = params[:current_email]
  end

  def reset_password
    reset_token = params[:user][:reset_token]
    user = User.find_by(email: params[:user][:current_email])
    if !user.present?
      flash[:error] = "无此email。"
      redirect_to action: :edit, id: current_user.id
    elsif user.reset_token != reset_token
      flash[:error] = "无效的重置token。"
      redirect_to action: :edit, id: current_user.id
    elsif user.expired_at < Time.zone.now
      flash[:error] = "token已过期，请重新申请重置密码。"
      redirect_to action: :edit, id: current_user.id
    else
      user.update(user_params)
      flash[:success] = "密码修改成功"
      redirect_to controller: :sessions_controller, action: :create
    end
  rescue Exception => e
    flash[:error] = e.message
    log_error user, e.message, '', e.backtrace
    redirect_to controller: :sessions_controller, action: :create
  end


  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :tel, :name, :company_name
    )
  end
end
