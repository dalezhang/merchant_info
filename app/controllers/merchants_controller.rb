# frozen_string_literal: true

class MerchantsController < ResourcesController
  authorize_resource

  def new
    @object = Merchant.new
    @object.user = current_user
  end

  def create
    params.permit!
    @object = Merchant.new(params[object_name.singularize.parameterize('_')])
    @object.user = current_user
    if @object.save
      flash[:success] = '保存成功，请继续完善信息。'
      redirect_to action: :edit, id: @object.id.to_s
    else
      flash[:error] = @object.errors.full_messages
      render 'new'
    end
  end

  def update
    load_object
    if [1, 3].include?(@object.status)
      super
    else
      flash[:error] = "数据已经锁定，不能修改。"
      redirect_to action: :show, id: @object.id.to_s
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
    url = begin
            target.avatar.url
          rescue
            nil
          end
    render json: { error: @error, url: url }.to_json
  end

  def load_collection
    @collection = current_user.merchants
  end

  def load_object
    load_collection
    @object = @collection.find(params[:id])
  end
end
