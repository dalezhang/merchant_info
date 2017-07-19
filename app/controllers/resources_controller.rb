# frozen_string_literal: true

class ResourcesController < AdminController
  before_action :authenticate_user!

  def select
    load_collection
  end

  def search
    render 'search', layout: nil
  end

  def index
    return @collection if @collection.present?
    load_collection
    @collection = @collection.paginate(page: params[:page], :per_page => 15)
  end

  def show
    load_object
    respond_to do |format|
      format.html
      format.js
      # format.json { render json: @object }
    end
  end

  def edit
    load_object
  end

  def new
    @object = object_name.classify.constantize.new
  end

  def update
    load_object
    params.permit!
    @object.attributes = params[object_name.singularize.parameterize('_')]
    if @object.changed_for_autosave?(@object)
      # @changes = @object.all_changes
      if @object.valid?
        @object.save
      else
        flash[:error] = @object.errors.full_messages.to_sentence
      end
    end
    respond_to do |format|
      format.html { redirect_to controller: controller_name, action: :show }
      format.json { respond_with_bip(@object) }
      format.js
    end
  rescue Exception => e
    @message = if e.class == Mongoid::Errors::Validations
                  @merchant.errors.messages.values.flatten.join
               else
                 e.message
               end
    log_error @object, @message, '', e.backtrace, params
    render json: { error: e.message }.to_json
  end

  def create
    params.permit!
    @object = object_name.classify.constantize.new(params[object_name.singularize.parameterize('_')])
    if @object.valid?
      @object.save
    else
      flash[:error] = @object.errors.full_messages.to_sentence
    end
    respond_to do |format|
      format.html { redirect_to @object }
      format.js
    end
  end

  def destroy
    load_object
    if @object.destroy
      flash[:success] = '删除成功'
    else
      flash[:error] = '删除失败'
    end
    redirect_to action: :index
  end

  protected

  def load_collection
    params[:q] ||= {}
    query = {}
    params[:q].each do |k,v|
      query[k] = Regexp.new(v) if v.present?
    end
    @collection = object_name.camelize.constantize.where(query).order('created_at desc')
  end

  def load_object
    @object ||= object_name.classify.constantize.find(params[:id])
  end

  def object_name
    controller_name.singularize
  end

  # Index request for JSON needs to pass a CSRF token in order to prevent JSON Hijacking
  def check_json_authenticity
    return unless request.format.js? || request.format.json?
    return unless protect_against_forgery?
    auth_token = params[request_forgery_protection_token]
    unless auth_token && form_authenticity_token == URI.unescape(auth_token)
      raise(ActionController::InvalidAuthenticityToken)
    end
  end

  # URL helpers

  def new_object_url(options = {})
    if parent_data.present?
      new_polymorphic_url([:admin, parent, model_class], options)
    else
      new_polymorphic_url([:admin, model_class], options)
    end
  end

  def edit_object_url(object, options = {})
    if parent_data.present?
      send "edit_#{model_name}_#{object_name}_url", parent, object, options
    else
      send "edit_#{object_name}_url", object, options
    end
  end

  def object_url(object = nil, options = {})
    target = object ? object : @object
    if parent_data.present?
      send "#{model_name}_#{object_name}_url", parent, target, options
    else
      send "#{object_name}_url", target, options
    end
  end

  def collection_url(_options = {})
    if parent_data.present?
      polymorphic_url([parent, model_class])
    else
      polymorphic_url(model_class)
    end
  end
end
