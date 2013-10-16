class StatsController < ApplicationController

  # GET /scoreboard
  def scoreboard
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    # load data from db
    @stats = Stat.order(:ordinal)
    @max_week = Chefstat.maximum(:week)
    users = User.includes(:chefs)
    chefstats = Chefstat.all
    picks = Pick.includes(:chef)

    # convert data to maps
    chef_id_to_points_map =
        build_chef_id_to_points_map(chefstats, build_stat_id_to_stat_map(@stats))
    eliminated_chef_ids =
        build_stat_id_to_chef_ids_map(chefstats)[build_stat_abbr_to_stat_map(@stats)["E"].id]
    @user_id_to_points_chefs_map =
        build_user_id_to_points_chefs_map(users, chef_id_to_points_map, eliminated_chef_ids)
    @user_id_to_users_map = build_user_id_to_user_map(users)

    @chef_id_to_stat_id_map = build_chef_id_week_to_stat_ids_map(chefstats)
    @stat_id_to_stat_map = build_stat_id_to_stat_map(@stats)
 
    @user_week_record_to_picks_map = build_user_week_record_to_pick_map(picks)
  end

  # GET /scores
  def scores
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @current_week = current_week_number
    @selected_week = @current_week    
  end

  # GET /scores/week/:number
  def scores_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @current_week = current_week_number
    @selected_week = params[:number].to_i
    render "scores"
  end

  # GET /ajax/scores/week/:number
  def ajax_scores_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    # only let user see weeks that have completed
    @week = Week.where(number: params[:number].to_i).first
    if @week && DateTime.now > @week.start_time
      @chefs = Chef.order(:first_name)
      @chef_id_to_stat_id_map = build_chef_id_to_stat_ids_map(Chefstat.where(week: @week.number))
      @stat_abbr_to_stat_map = build_stat_abbr_to_stat_map(Stat.all)
    end
    render :layout => "ajax"
  end

  # POST /scores/week/:number
  def update_scores
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    week = params[:number].to_i
    confirmation_message = ""
    if params["updatescores"]
      chefstats = Chefstat.where(week: week)
      stat_id_to_chef_ids_map = build_stat_id_to_chef_ids_map(chefstats)
      chefstat_id_to_chefstat_map = build_chefstat_id_to_chefstat_map(chefstats)

      stats = Stat.order(:ordinal)

      Chefstat.transaction do
        begin
	      stats.each { |stat|
	        selected_chef_ids = params[stat.abbreviation].nil? ? [] :
	            params[stat.abbreviation].collect { |chef_id| chef_id.to_i }
	        existing_chef_ids = stat_id_to_chef_ids_map.has_key?(stat.id) ?
	              stat_id_to_chef_ids_map[stat.id] : []

	        # any ids in selected but not in existing should be created
	        (selected_chef_ids - existing_chef_ids).each { |chef_id|
	          chefstat = Chefstat.new
	          chefstat.week = week
	          chefstat.chef_id = chef_id
	          chefstat.stat_id = stat.id
	          chefstat.save
	        }

	        # any ids in existing but not in created should be deleted
	        (existing_chef_ids - selected_chef_ids).each { |chef_id|
	          chefstat = chefstat_id_to_chefstat_map[Chefstat::identifier(chef_id, stat.id, week)]
	          chefstat.destroy
	        }
	      }
	      confirmation_message = "Successfully updated scores!"
	    rescue Exception => e
          confirmation_message = "Error: Problem occurred while updating scores"
	    end
	  end
    elsif params["setpicks"]
      # TODO set weekly picks for next week
    end

    redirect_to "/scores/week/" + week.to_s, notice: confirmation_message
  end
end
