class ChefsController < ApplicationController
  # GET /chefs
  # GET /chefs.json
  def index
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    # load data from db
    @chefs = Chef.all
    draft_picks = DraftPick.all
    chefstats = Chefstat.all
    stats = Stat.all

    # TODO add sorting
    @chef_id_to_picks_map = build_chef_id_to_picks_map(draft_picks)
    @chef_id_to_points_map =
        build_chef_id_to_points_map(chefstats, build_stat_id_to_stat_map(stats))
    @chef_id_to_chef_map = build_chef_id_to_chef_map(@chefs)
    @chef_id_to_chefstats_map = build_chef_id_to_chefstats_map(chefstats)

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
  def ajax_chef
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
    @picks = Pick.includes(:user)
                 .where(chef_id: @selected_chef.id)
                 .order(:week, :number)

    render :layout => "ajax"
  end
end
