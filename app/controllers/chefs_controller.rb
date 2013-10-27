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

  # GET /chefs/:id
  def show
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end
    
    @chefs = Chef.order(:first_name, :last_name)
    @selected_chef = Chef.find(params[:id])
  end

  # GET /ajax/chefs/:id
  def ajax_show
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    @selected_chef = Chef.find(params[:id])
    chefstats = Chefstat.joins(:stat)
                        .where(chef_id: @selected_chef.id)
                        .order(:week, "stats.stat_type")
    @stattype_week_to_chefstats_map = build_stattype_week_to_chefstats_map(chefstats)
    @max_week = Chefstat.maximum(:week)

    render :layout => "ajax"
  end
end
