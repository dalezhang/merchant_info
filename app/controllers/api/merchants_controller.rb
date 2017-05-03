class Api::MerchantsController < ActionController::API
	def create
		jwt = params[:jwt]
		arr = Biz::Jwt.h5_verify? jwt
		unless data[0]
			render json: {error: 'invalid jwt'}
			return
		end
		data = arr[1]
		data.deep_symbolized_keys!
		@user = User.find_by(token: data[:token])
		unless @user
			render json: {error: 'invalid token'}
			return
		end
		case data[:method]
		when 'merchant.create'
			@merchant = Merchant.new(user: @user)
			keys = data.keys & Merchant.attr_writeable
			keys.each do |key|
				@merchant.send("#{key}=", data[1][key])
			end
		when 'update'
			@merchant = Merchant.find
		end
		if @merchant.save
			render json: @merchant.inspect.to_json
		else
			render json: {error: @merchant.errors.messages}.to_json
		end
	end
	def upload_picture
		render json: {url: @img.avatar.url, token: @img.token}.to_json
	end
end