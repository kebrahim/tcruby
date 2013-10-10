class ChefsController < ApplicationController
  # GET /chefs
  # GET /chefs.json
  def index
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    # TODO add sorting
    @chefs = Chef.order(:last_name, :first_name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chefs }
    end
  end
end
