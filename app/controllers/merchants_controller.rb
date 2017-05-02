class MerchantsController < ResourcesController

	def create
		params.permit!
		@object = current_user.merchants.new(params[object_name.singularize.parameterize('_')])
		if @object.save
			flash[:success] = '保存成功，请继续完善信息。'
			redirect_to action: :edit, id: @object.id.to_s
		else
			flash[:error] = @object.errors.full_messages
			render 'new'
		end
	end

  def upload_picture
    @error = nil
    call_stacks = params[:resource_attrname].split('/')
    load_object
    target = @object
    begin
      params.permit(:file)
      call_stacks.each do |method|
        target = target.__send__(method)
      end
      target.avatar = params[:file].tempfile
      target.save!
      @object.save!
    rescue => e
      @error = e.messages.join(';')
    end
    url = target.avatar.url rescue nil
    render json: {error: @error , url: url}.to_json
  end
end
