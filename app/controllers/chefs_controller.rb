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
    @chef_id_to_picks_map = build_chef_id_to_picks_map(DraftPick.all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chefs }
    end
  end
end
