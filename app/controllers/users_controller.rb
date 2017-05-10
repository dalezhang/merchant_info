# frozen_string_literal: true

class UsersController < ResourcesController
  authorize_resource
  def update
    load_object
    @object.bucket_name = params[:user][:bucket_name]
    @object.bucket_url = params[:user][:bucket_url]
    role = Role.find_by(name: params[:user][:roles])
    @object.roles = [role]
    if @object.save
      flash[:success] = '修改成功'
    else
      flash[:error] = "修改失败: #{@object.errors.messages.join('\n')}"
    end
    redirect_to @object
  end
end
