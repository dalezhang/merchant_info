class UploadImgController < ApplicationController
	layout 'login'
	def index
    @uptoken = Biz::QiniuApi.generate_token
	end
end
