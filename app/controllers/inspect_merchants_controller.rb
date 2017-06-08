# frozen_string_literal: true

class InspectMerchantsController < ResourcesController
  include Logging
  authorize_resource class: 'Merchant'
  before_action :authorize_current_user
  def authorize_current_user
    redirect_to '/' unless current_user.roles.pluck(:name).include?('admin')
  end

  def change_status
    load_object
    if @object.update(status: Merchant::STATUS_DATA.invert[params[:status]])
      flash[:success] = '状态修改成功'
    else
      flash[:error] = "未知状态：#{params[:status]}"
    end
    redirect_to action: :index
  end

  def prepare_request
    load_object
    zx_biz = Biz::ZxMctInfo.new @object
    pfb_biz = Biz::PfbMctInfo.new @object
    if !zx_biz.prepare_request || !pfb_biz.prepare_request
      flash[:error] = '数据生成报错！'
    else
      flash[:success] = '数据生成成功！'
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace
    redirect_to action: :show, id: @object.id.to_s
  end
  def get_merchant_id
    load_object
    core_account = Biz::CoreAccount.new(@object)
    if @object.merchant_id.present?
      flash[:success] = 'merchant_id已经存在！'
    elsif !core_account.create_backend_account
      flash[:error] = core_account.error_message
    else
      flash[:success] = '数据生成成功！'
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace
    redirect_to action: :show, id: @object.id.to_s

  end

  def zx_infc
    load_object
    bz = Biz::ZxInfcApi.new(@object, params[:channel])
    result = bz.send_intfc(params[:req_typ])
    if result
      flash[:success] = result
    else
      flash[:error] = bz.error_message
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace
    redirect_to action: :show, id: @object.id.to_s
  end

  def pfb_infc
    load_object
    bz = Biz::PfbInfcApi.new(@object.merchant_id, params[:channel])
    result = bz.send_intfc(params[:req_typ])
    if result
      flash[:success] = result
    else
      flash[:error] = bz.error_message
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace
    redirect_to action: :show, id: @object.id.to_s
  end

  def object_name
    'merchant'
  end
end
