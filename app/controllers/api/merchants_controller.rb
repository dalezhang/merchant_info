# frozen_string_literal: true

class Api::MerchantsController < ActionController::API
  include Logging
  # before_action :get_user, :decode_data
  def create
    ErrorLog.create(
        sender: nil, err_title: 'params', err_message: '', params: params.to_h
      )

    case @data[:method]
    when 'merchant.create'
      @merchant = Merchant.new(user: @user)
      keys = @data.keys & Merchant.attr_writeable
      keys.each do |key|
        @merchant.send("#{key}=", @data[key])
      end
    when 'merchant.update'
      if @data[:out_merchant_id].present?
        @merchant = @user.merchants.find_by(out_merchant_id: @data[:out_merchant_id])
      elsif @data[:merchant_id].present?
        @merchant = @user.merchants.find_by(merchant_id: @data[:merchant_id])
      elsif @data[:id].present?
        @merchant = @user.merchants.find_by(id: @data[:id])
      end
      unless @merchant.present?
        render json: { error: 'invalid id' }.to_json
        return
      end
      keys = @data.keys & Merchant.attr_writeable
      keys.each do |key|
        @merchant.send("#{key}=", @data[key])
      end
    when 'merchant.query'
      @merchant = @user.merchant.find_by(out_merchant_id: @data[:out_merchant_id])
      if @merchant.present?
        render json: @merchant.inspect.to_json
      else
        render json: { error: 'invalid id' }.to_json
      end
      return
    else
      render json: { error: 'invalid method, should be one of ["merchant.create","merchant.update","merchant.query"]' }.to_json
      return
    end
    if @merchant.save
      render json: @merchant.inspect.to_json
    else
      render json: { error: @merchant.errors.messages }.to_json
    end
  rescue Exception => e
    log_error @merchant, e.message, '', e.backtrace, params
    render json: { error: e.message }.to_json
  end

  private
  def decode_data
    jwt = params[:jwt]
    sign = params[:sign]
    @data = nil
    if jwt.present?
      @data = jwt_decode
    elsif sign.present?
      @data = md5_decode
    else
      raise "缺少字段： ‘jwt’ 或 ‘sign’"
    end
  rescue Exception => e
    log_error @merchant, e.message, '', e.backtrace, params
    render json: { error: e.message }.to_json
  end

  def jwt_decode
    decoder = Biz::Jwt.new(params[:partner_id])
    arr = decoder.h5_verify? params[:jwt]
    unless arr[0]
      raise  'invalid jwt' 
    end
    arr[1].deep_symbolize_keys
  end

  def md5_decode
    get_user unless @user.present?
    key = @user.token
    if params[:sign] == get_mac(params,key)
      return params.deep_symbolize_keys
    else
      raise '签名错'
    end
  end

  def get_mab(js)
    mab = []
    js.keys.sort.each do |k|
      mab << "#{k}=#{js[k].to_s}" if ![:mac, :sign, :controller, :action ].include?(k.to_sym) && js[k]
    end
    mab.join('&')
  end
  def md5(str)
    Digest::MD5.hexdigest(str)
  end
  def get_mac(js, key)
    md5(get_mab(js) + "&key=#{key}").upcase
  end

  def get_user
    unless params[:partner_id].present?
      raise 'partner_id为空'
    end
    @user = User.find_by(partner_id: params[:partner_id])
    unless @user.present?
      raise '找不到代理商信息，partner_id无效。'
    end
  rescue Exception => e
    log_error @merchant, e.message, '', e.backtrace, params
    render json: { error: e}.to_json
  end
end
