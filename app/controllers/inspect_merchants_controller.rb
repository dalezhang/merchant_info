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
      flash[:success] = '数据生成成功！点击“查询支付渠道信息”查看详情'
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end
  def get_backend_account
    load_object
    core_account = Biz::CoreAccount.new(@object)
    pay_route = Biz::PayRoute::PayRouteBase.new @object
      @message = "路由创建成功，返回内容已保存在request_and_response.pfb_response[:pay_route_query]"
    if @object.merchant_id.present?
      core_account.get_backend_account
      pay_route.query
    else
      core_account.create_backend_account # 提交创建请求
      core_account.get_backend_account # 查询创建结果
      pay_route.query
    end
    if core_account.has_error
      flash[:success] = '数据获取成功！请到request_and_response=>core_account中查看。'
    else
      flash[:error] = core_account.error_message
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end

  # def update_backend_account
  #   load_object
  #   core_account = Biz::CoreAccount.new(@object)
  #   if @object.merchant_id.present?
  #     if core_account.update_backend_account
  #       flash[:success] = '数据获取成功！'
  #     else
  #       flash[:error] = core_account.error_message
  #     end
  #   elsif !core_account.create_backend_account
  #     flash[:error] = core_account.error_message
  #   else
  #     flash[:success] = '数据生成成功！'
  #   end
  #   redirect_to action: :show, id: @object.id.to_s
  # rescue Exception => e
  #   flash[:error] = e.message
  #   log_error @object, e.message, '', e.backtrace, params
  #   redirect_to action: :show, id: @object.id.to_s
  # end
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
    log_error @object, e.message, '', e.backtrace, params
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
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end

  def pfb_infc
    load_object
    bz = Biz::PfbInfcApi.new(@object.id, params[:channel])
    result = bz.send_intfc(params[:req_typ])
    if result
      flash[:success] = result
    else
      flash[:error] = bz.error_message
    end
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end

  def create_pay_route
    load_object
    @message = nil
    case params[:route]
    when 'bjrcb.wechat_offline'
      biz = Biz::PayRoute::BjrcbPayRoute.new @object
      biz.send_wechat_offline
      @message = "路由创建成功，返回内容已保存在request_and_response[:pfb_response][:bjrbc_pay_route][:wechat_offline]"
    when 'bjrcb.alipay'
      biz = Biz::PayRoute::BjrcbPayRoute.new @object
      biz.send_alipay
      @message = "路由创建成功，返回内容已保存在request_and_response[:pfb_response][:bjrbc_pay_route][:wechat_offline]"
    end
    flash[:success] = @message
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end

  def object_name
    'merchant'
  end
end
