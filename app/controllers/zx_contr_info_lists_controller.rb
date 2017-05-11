class ZxContrInfoListsController < ResourcesController
  def load_object
    @object = Merchant.find(params[:inspect_merchant_id]).zx_contr_info_lists.find(params[:id])
  end
  def update
    load_object
    params.permit!
    @object.attributes = params[object_name.singularize.parameterize('_')]
    if @object.changed_for_autosave?(@object)
      # @changes = @object.all_changes
      if @object.save
      else
        flash[:error] = @object.errors.full_messages.to_sentence
        @no_log = 1
      end
    end
    redirect_to controller: :inspect_merchants, action: :edit, id: params[:inspect_merchant_id]
  end
  def create
    params.permit!
    @object = Merchant.find(params[:inspect_merchant_id]).zx_contr_info_lists.new(params[object_name.singularize.parameterize('_')])
    unless @object.save
      flash[:error] = @object.errors.full_messages.to_sentence
      @no_log = 1
    end
    redirect_to controller: :inspect_merchants, action: :edit, id: params[:inspect_merchant_id]
  end
end