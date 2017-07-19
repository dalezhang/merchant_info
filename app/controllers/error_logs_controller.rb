# frozen_string_literal: true

class ErrorLogsController < ResourcesController
  authorize_resource
  def destroy_all
    if ErrorLog.destroy_all
      flash[:success] = '删除成功'
    end
    redirect_to action: :index
  end
end
