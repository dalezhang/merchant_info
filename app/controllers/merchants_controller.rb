class MerchantsController < ResourcesController

  def index
    if current_user.merchant && current_user.merchant.status == 1
      	redirect_to action: :show
	elsif current_user.merchant
		redirect_to action: :edit, id: current_user.merchant.id
    else
      redirect_to action: :new
    end
  end

end
