class ChefsController < ApplicationController
  helper_method :sort_column, :sort_direction

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
    chefstats = Chefstat.all
    stats = Stat.all
    @all_draft_picks = DraftPick.all

    @sort_column = sort_column
    @sort_direction = sort_direction
    @draft_picks = load_draft_picks(@sort_column, @sort_direction)

    @chef_id_to_picks_map = build_chef_id_to_picks_map(@all_draft_picks)
    @chef_id_to_points_map =
        build_chef_id_to_points_map(chefstats, build_stat_id_to_stat_map(stats))
    @chef_id_to_chef_map = build_chef_id_to_chef_map(@chefs)
    @chef_id_to_chefstats_map = build_chef_id_to_chefstats_map(chefstats)
    @chef_id_to_elimweek_map = build_chef_id_to_elimweek_map(chefstats)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @chefs }
    end
  end

  def load_draft_picks(column, direction)
    case column.to_s
    when :chef.to_s
      return DraftPick.includes(:chef)
                      .where(league: :poboy)
                      .order("chefs.first_name " + direction)
    when :poboy.to_s
      return DraftPick.where(league: :poboy)
                      .order("round " + direction + ", pick " + direction)
    when :beignet.to_s
      return DraftPick.where(league: :beignet)
                      .order("round " + direction + ", pick " + direction)
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

  private
  
  def sort_column
    DraftPick::SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : :chef.to_s
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end 
end
