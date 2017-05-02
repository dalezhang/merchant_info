class Api::MerchantsController < ActionController::API
	def create
		jwt = params[:jwt]
		data = Biz::Jwt.h5_verify? jwt
		@user = User.find_by(token: data['token'])
		@merchant = Merchant.new(user: @user)
		data.each do |key,value|
			if @merchant.respond_to?(key)
				@merchant.send("#{key}=", value)
			end
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