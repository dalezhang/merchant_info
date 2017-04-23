class MerchantsController < ResourcesController

  def index
    if current_user.merchant && current_user.merchant.status == 1
      redirect_to action: :show
    else
      redirect_to action: :edit
    end
  end

end
