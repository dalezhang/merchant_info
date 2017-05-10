# frozen_string_literal: true

class Api::MerchantsController < ActionController::API
  def create
    jwt = params[:jwt]
    arr = Biz::Jwt.h5_verify? jwt
    unless arr[0]
      render json: { error: 'invalid jwt' }
      return
    end
    data = arr[1].deep_symbolize_keys
    @user = User.find_by(token: data[:token])
    unless @user.present?
      render json: { error: 'invalid token' }.to_json
      return
      end
    case data[:method]
    when 'merchant.create'
      @merchant = Merchant.new(user: @user)
      keys = data.keys & Merchant.attr_writeable
      keys.each do |key|
        @merchant.send("#{key}=", data[1][key])
      end
    when 'merchant.update'
      @merchant = @user.merchant.find_by(out_merchant_id: data[:out_merchant_id])
      unless @merchant.present?
        render json: { error: 'invalid id' }.to_json
        return
      end
      keys = data.keys & Merchant.attr_writeable
      keys.each do |key|
        @merchant.send("#{key}=", data[key])
      end
    when 'merchant.query'
      @merchant = @user.merchant.find_by(out_merchant_id: data[:out_merchant_id])
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
  end
end
