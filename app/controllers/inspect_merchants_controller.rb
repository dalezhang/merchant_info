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

  def prepare_request
    load_object
    biz = Biz::ZxMctInfo.new @object
    if !biz.prepare_request
      flash[:error] = "数据生成报错！"
    elsif !Biz::CoreAccount.create_backend_account(@object)
      flash[:error] = "merchant_id生成报错！"
    else
      flash[:success] = "数据生成成功！"
    end
    redirect_to action: :show, id: @object.id.to_s
  end

  def zx_infc
    load_object
    case params[:req_typ]
    when '新增'
      send_request 0
    when '变更'
      send_request 1
    when '停用'
      send_request 2
    when '查询'
      bz = Biz::ZxInfcApi.new(@object.merchant_id,params[:channel])
      response_hash = bz.send_query
      if response_hash
        @object.request_and_response.zx_response["#{params[:channel]}_query"] = response_hash
        @object.save
        flash[:success] = "返回信息已保存在request_and_response.zx_response"
      else
        flash[:error] = "无返回信息"
      end
    else
      flash[:error] = "未知的请求类型"
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    redirect_to action: :show, id: @object.id.to_s
  end

  def object_name
    'merchant'
  end
  private
  def send_request(appl_typ)
    bz = Biz::ZxInfcApi.new(@object.merchant_id,params[:channel])
    response_xml = bz.send_intfc(appl_typ)
    if response_xml
      # @object.request_and_response.zx_reponse["#{params[:channel]}_#{params[:req_typ]}"] = Hash.from_xml(response_xml)
      # @object.save
      flash[:success] = "返回信息已保存在request_and_response.zx_reponse"
    else
      flash[:error] = "无返回信息"
    end
  end
end
