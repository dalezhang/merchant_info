# frozen_string_literal: true

class UploadImgController < AdminController
  def index
    @uptoken = Biz::QiniuApi.generate_token(current_user.bucket_name)
  end
end
