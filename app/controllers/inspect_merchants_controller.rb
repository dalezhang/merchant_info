# frozen_string_literal: true

class InspectMerchantsController < ResourcesController
  authorize_resource class: 'Merchant'
  before_action :authorize_current_user
  def authorize_current_user
    redirect_to '/' unless current_user.roles.pluck(:name).include?('admin')
  end

  def routes
    load_object
  end
  def add_route
    load_object
    @hash = {}
    @zx_response = @object.request_and_response.zx_response.deep_symbolize_keys rescue nil
    @hash[:zx_wechat_channel_mch_id] = @zx_response.deep_symbolize_keys[:wechat_query][:ROOT][:Mercht_Idtfy_Num] rescue nil
    @hash[:zx_alipay_channel_mch_id] = @zx_response.deep_symbolize_keys[:alipay_query][:ROOT][:Mercht_Idtfy_Num] rescue nil
    @pfb_response = @object.request_and_response.pfb_response.deep_symbolize_keys rescue nil
    query_customer_num = @pfb_response[:wechat_offline_查询][:customer][:customerNum] rescue nil
    response_customer_num = @pfb_response[:wechat_offline_新增][:customer_num] rescue nil
    @hash[:pfb_wechat_offline_channel_mch_id] = response_customer_num || query_customer_num
    query_api_key = @pfb_response[:wechat_offline_查询][:customer][:apiKey] rescue nil
    response_api_key = @pfb_response[:wechat_offline_新增][:api_key] rescue nil
    @hash[:pfb_wechat_offline_api_key] = response_api_key || query_api_key
    query_customer_num = @pfb_response[:alipay_查询][:customer][:customerNum] rescue nil
    response_customer_num = @pfb_response[:alipay_新增][:customer_num] rescue nil
    @hash[:pfb_alipay_channel_mch_id] = response_customer_num || query_customer_num
    query_api_key = @pfb_response[:alipay_查询][:customer][:apiKey] rescue nil
    response_api_key = @pfb_response[:alipay_新增][:api_key] rescue nil
    @hash[:pfb_alipay_api_key] = response_api_key || query_api_key
  end

  def update
    load_object

    super
  end

  def change_status
    load_object
    if @object.update(status: Merchant::STATUS_DATA.invert[params[:status]])
      flash[:success] = '状态修改成功'
    else
      flash[:error] = "未知状态：#{params[:status]}"
    end
    redirect_to action: :show, id: @object.id
  end
  def change_pay_route_status
    load_object
    if @object.pay_route_status.update("#{params[:route]}": Merchant::PAY_ROUTE_STATUS_DATA.invert[params[:status]])
      flash[:success] = '状态修改成功'
    else
      flash[:error] = "未知状态：#{params[:status]}"
    end
    redirect_to action: :show, id: @object.id
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
       # flash[:info] = result
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
       # flash[:info] = result
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
    case params[:route]
    when 'bjrcb.wechat_offline'
      biz = Biz::PayRoute::BjrcbPayRoute.new @object, params[:channel_type]
      biz.send_wechat_offline
    when 'bjrcb.alipay'
      biz = Biz::PayRoute::BjrcbPayRoute.new @object, params[:channel_type]
      biz.send_alipay
    when 'CITIC_WECHAT'
      biz = Biz::PayRoute::ZxAlipayPayRoute.new @object
      biz.send_wechat
    when 'CITIC_ALI'
      biz = Biz::PayRoute::ZxAlipayPayRoute.new @object
      biz.send_alipay
    end
    flash[:success] = "路由创建成功"
    redirect_to action: :show, id: @object.id.to_s
  rescue Exception => e
    flash[:error] = e.message
    log_error @object, e.message, '', e.backtrace, params
    redirect_to action: :show, id: @object.id.to_s
  end

  def load_collection
    @collection = Merchant.all
  end

  def load_object
    @object = Merchant.find(params[:id])
    raise "can't find Merchant by id #{params[:id]}" unless @object.present?
  end
  def object_name
    "merchant"
  end
end
