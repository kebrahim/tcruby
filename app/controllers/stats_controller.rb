class StatsController < ApplicationController
  skip_before_filter :verify_authenticity_token

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
    @user_id_to_points_chefs_map =
        build_user_id_to_points_chefs_map(users, chefstats, @stats, picks)
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
      picks = Pick.where(week: week).order(:number)

      Chefstat.transaction do
        begin
          winning_chef_ids = []
          eliminated_chef_ids = []
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

	        # save winner/eliminated chef ids
            if (stat.abbreviation == Stat::WINNER_ABBR)
              winning_chef_ids = selected_chef_ids
            elsif (stat.abbreviation == Stat::ELIMINATED_ABBR)
              eliminated_chef_ids = selected_chef_ids
            end
	      }

          # update picks
          update_pick_scores(picks, winning_chef_ids, eliminated_chef_ids)

	      confirmation_message = "Successfully updated scores!"
	    rescue Exception => e
          confirmation_message = "Error: Problem occurred while updating scores: " + e.message
	    end
	  end
    elsif params["setpicks"]
      next_week = week + 1
      Pick.transaction do
        begin
	      # if any picks exist for next week, destroy them
	      Pick.where(week: next_week).destroy_all

	      # create weekly picks for next week based on reverse order of standings
          users = User.includes(:chefs)
          chefstats = Chefstat.all
          picks = Pick.includes(:chef)

	      user_id_to_points_chefs_map =
	          build_user_id_to_points_chefs_map(users, chefstats, Stat.all, picks)
	      pickcount = 0
	      user_id_to_points_chefs_map.sort_by { |k,v| v["points"] }.each { |user_points|
	      	pickcount += 1
	        create_pick(next_week, user_points[0], pickcount)
	        create_pick(next_week, user_points[0], (((2 * users.count) + 1) - pickcount))
	      }
		  confirmation_message = "Successfully updated picks!"
	    rescue Exception => e
          confirmation_message = "Error: Problem occurred while updating picks: " + e.message
	    end
	  end
    end

    redirect_to "/scores/week/" + week.to_s, notice: confirmation_message
  end

  def create_pick(week, user_id, number)
    pick = Pick.new
    pick.week = week
    pick.user_id = user_id
    pick.number = number
    pick.points = nil
    pick.save
  end

  def update_pick_scores(picks, winning_chef_ids, eliminated_chef_ids)
  	picks.each { |pick|
      expected_pick_points = (pick.record.to_s == :win.to_s) ?
          get_expected_pick_points(pick, winning_chef_ids, eliminated_chef_ids) :
          get_expected_pick_points(pick, eliminated_chef_ids, winning_chef_ids)
      if expected_pick_points != pick.points
        # pick doesn't have correct score; update it!
        pick.update_attribute(:points, expected_pick_points)
      end
  	}
  end

  def get_expected_pick_points(pick, record_chef_ids, non_record_chef_ids)
    if record_chef_ids.include?(pick.chef_id)
      # chef & record is correct. points are based on week
      return [(Pick::MAX_BONUS - ((pick.week - 1) / Pick::WEEKLY_STEP)), 0].max
    elsif non_record_chef_ids.include?(pick.chef_id)
      # chef is correct, but record is not; return mismatch penalty
      return Pick::MISMATCH_PENALTY;
    else
      return 0
    end
  end
end
