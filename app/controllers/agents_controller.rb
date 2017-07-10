# frozen_string_literal: true
class AgentsController < ResourcesController
  authorize_resource
  def update
    load_object
    @object.update!(agent_update_params)
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
  def agent_update_params
    params.require(:agent).permit(
      :share_rate, :name
    )
  end

end
