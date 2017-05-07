class InspectMerchantsController < ResourcesController

  def change_status
    load_object
    if @object.update(status: Merchant::STATUS_DATA.invert[params[:status]])
      flash[:success] = "状态修改成功"
    else
      flash[:error] = "未知状态：#{params[:status]}"
    end
    redirect_to action: :index

  end

  def object_name
    'merchant'
  end
end
