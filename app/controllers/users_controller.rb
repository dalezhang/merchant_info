# frozen_string_literal: true

class UsersController < ResourcesController
  authorize_resource
  before_action :list_roles
  def create
    @object = User.new(user_params)
    if @object.save
      flash[:success] = '用户创建成功。'
    else
      flash[:error] = @object.errors.messages
    end
    redirect_to @object
  rescue Exception => e
    @message = if e.class = Mongoid::Errors::Validations
                 @object.errors.messages.values.flatten.join
               else
                 e.message
               end
    flash[:error] = "创建失败: #{@message}"
    render 'new'
  end

  def update
    load_object
    role_arr = []
    (params[:user][:roles] || []).each do |n|
      role = Role.find_by(chinese_name: n)
      role_arr << role if role.present?
    end
    @object.update!(user_params.merge(roles: role_arr))
    flash[:success] = '修改成功'
    redirect_to @object
  rescue Exception => e
    @message = if e.class == Mongoid::Errors::Validations
                 @object.errors.messages.values.flatten.join
               else
                 e.message
               end
    flash[:error] = "修改失败: #{@message}"
    redirect_to @object
  end

  private

  def list_roles
    @roles = []
    Role.all.map do |obj|
      @roles << [obj.id.to_s, obj.name ]
    end
  end

  def load_collection
    if current_user.roles.pluck(:name).include? 'admin'
      @collection = object_name.camelize.constantize.all
    elsif current_user.roles.pluck(:name).include? 'agent'
      @collection = current_user.children
    else
      @collection = []
      flash[:error] = "没有用户信息，请确认你的权限。"
    end
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :bucket_name, :bucket_url,
      :tel, :name, :company_name, :partner_id, :agent_id
    )
  end
end
