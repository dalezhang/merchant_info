# frozen_string_literal: true

class UsersController < ResourcesController
  authorize_resource
  def create
    @object = User.new(user_params)
    @object.save!
    flash[:success] = '用户创建成功。'
    redirect_to @object
  rescue Exception => e
    if e.class = Mongoid::Errors::Validations
      @message = @object.errors.messages.values.flatten.join
    else
      @message = e.message
    end
    flash[:error] = "创建失败: #{@message}"
    render 'new'
  end
  def update
    load_object
    role = Role.find_by(name: params[:user][:roles])
    @object.roles = [role]
    @object.update!(user_params.merge({roles: [role]}))
    flash[:success] = '修改成功'
    redirect_to @object
  rescue Exception => e
    if e.class = Mongoid::Errors::Validations
      @message = @object.errors.messages.values.flatten.join
    else
      @message = e.message
    end
    flash[:error] = "修改失败: #{@message}"
    redirect_to @object
  end

  private
  def user_params
    params.require(:user).permit(
			:email, :password, :password_confirmation, :bucket_name, :bucket_url
    )
  end
end
