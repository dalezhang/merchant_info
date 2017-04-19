class ExamineProductDraftsController < ResourcesController
  def index
    collection
  end

  def update
    if @examine_product_draft.update(product_draft_params)
      render json: @examine_product_draft
    else
      render json: @examine_product_draft.errors, status: :unprocessable_entity
    end
  end

  def destroy
    product_code = @examine_product_draft.product_code
    name = @examine_product_draft.name
    @examine_product_draft.delete
		if request.format.json?
      head :no_content
    else
      flash[:success] = "destroy successfully! product_code: #{product_code}, name: #{name}"
      redirect_to action: :index
		end
  end

	private

	def collection
    @collection = @examine_product_drafts
    params[:q] ||= {}
    only_examined = params[:q].delete(:only_examined)
    if only_examined == '0'
      @collection = @collection.where('examine is true')
    end
		@search = @collection.ransack(params[:q])
		if request.format.csv?
			@collection = @search.result
				.includes(:variants)
        .order('id asc')
		else
			@collection = @search.result
				.includes(:variants)
        .order('id asc')
				.paginate(page: params[:page], per_page: 30)
		end
	end

	def product_draft_params
    case params[:product_draft][:examine]
    when 'true'
      params[:product_draft][:examine] = true
    when 'false'
      params[:product_draft][:examine] = false
    end
		params.require(:product_draft).permit(ProductDraft.attribute_names)
	end

end
