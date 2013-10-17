class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  helper_method :current_user
  before_filter :set_time_zone

  private

  # returns the current logged-in user
  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end

  # logs the current user out of the system
  def logout_user
    cookies.delete(:auth_token)
  end

  # sets the time zone to the time zone of the current user
  def set_time_zone
    Time.zone = "Eastern Time (US & Canada)"
  end

  # returns the current week number of all weeks
  def current_week_number
    return get_current_week_number_from_weeks(Week.order(:number))
  end

  # returns the current week number, from the specified array of weeks, based on the weeks' start times
  def get_current_week_number_from_weeks(weeks)
    now = DateTime.now
    weeks.each { |week|
      if now < week.start_time
        return (week.number - 1)
      end
    }
    return weeks.last.number
  end

  # returns the first pick in the list which doesn't have a selected chef, or nil if they all have a
  # selected chef
  def current_pick(picks)
    picks.each { |pick|
      if !pick.chef_id.nil?
        next
      end
      return pick
    }
    return nil
  end

  def build_chef_id_to_pick_map(picks)
    chef_id_to_pick_map = {}
    picks.each { |pick|
      chef_id_to_pick_map[pick.chef_id] = pick
    }
    return chef_id_to_pick_map
  end

  def build_chef_id_to_picks_map(picks)
    chef_id_to_pick_map = {}
    picks.each { |pick|
      if !chef_id_to_pick_map.has_key?(pick.chef_id)
        chef_id_to_pick_map[pick.chef_id] = []    
      end
      chef_id_to_pick_map[pick.chef_id] << pick
    }
    return chef_id_to_pick_map
  end

  # map of chef_id to a map of week number to an array of stat ids
  def build_chef_id_week_to_stat_ids_map(chefstats)
    chef_id_to_stat_map = {}
    chefstats.each { |chefstat|
      if !chef_id_to_stat_map.has_key?(chefstat.chef_id)
        chef_id_to_stat_map[chefstat.chef_id] = {}
      end
      if !chef_id_to_stat_map[chefstat.chef_id].has_key?(chefstat.week)
        chef_id_to_stat_map[chefstat.chef_id][chefstat.week] = []
      end
      chef_id_to_stat_map[chefstat.chef_id][chefstat.week] << chefstat.stat_id
    }
    return chef_id_to_stat_map
  end

  # map of chef_id to an array of stat ids
  def build_chef_id_to_stat_ids_map(chefstats)
    chef_id_to_stat_map = {}
    chefstats.each { |chefstat|
      if !chef_id_to_stat_map.has_key?(chefstat.chef_id)
        chef_id_to_stat_map[chefstat.chef_id] = []
      end
      chef_id_to_stat_map[chefstat.chef_id] << chefstat.stat_id
    }
    return chef_id_to_stat_map
  end

  # map of chef_id to total points scored by that chef
  def build_chef_id_to_points_map(chefstats, stat_id_to_stat_map)
    chef_id_to_points_map = {}
    chefstats.each { |chefstat|
      if !chef_id_to_points_map.has_key?(chefstat.chef_id)
        chef_id_to_points_map[chefstat.chef_id] = 0
      end
      chef_id_to_points_map[chefstat.chef_id] += stat_id_to_stat_map[chefstat.stat_id].points
    }
    return chef_id_to_points_map
  end

  # map of user id to map of total points scored by all the chefs and number of non-eliminated chefs
  # on that user's team
  def build_user_id_to_points_chefs_map(users, chefstats, stats, picks)
    chef_id_to_points_map =
        build_chef_id_to_points_map(chefstats, build_stat_id_to_stat_map(stats))
    eliminated_chef_ids = build_stat_id_to_chef_ids_map(chefstats)[
        build_stat_abbr_to_stat_map(stats)[Stat::ELIMINATED_ABBR].id]
    user_id_to_picks_map = build_user_id_to_picks_map(picks)

    user_id_to_points_chefs_map = {}
    users.each { |user|
      user_id_to_points_chefs_map[user.id] = {}
      user_id_to_points_chefs_map[user.id]["points"] = 0
      user_id_to_points_chefs_map[user.id]["numchefs"] = 0

      # for each chef belonging to user, add total points scored and increment chefcount if chef has
      # not yet been eliminated
      user.chefs.each { |chef|
        user_id_to_points_chefs_map[user.id]["points"] += chef_id_to_points_map[chef.id]
        if !eliminated_chef_ids.include?(chef.id)
          user_id_to_points_chefs_map[user.id]["numchefs"] += 1
        end
      }

      # for each pick, add bonus points
      user_id_to_picks_map[user.id].each { |pick|
        user_id_to_points_chefs_map[user.id]["points"] += pick.points if pick.points
      }
    }
    return user_id_to_points_chefs_map
  end

  def build_user_week_record_to_pick_map(picks)
    user_week_record_to_pick_map = {}
    picks.each { |pick|
      user_week_record_to_pick_map[pick.my_user_week_record_id] = pick
    }
    return user_week_record_to_pick_map
  end

  def build_user_id_to_picks_map(picks)
    user_id_to_picks_map = {}
    picks.each { |pick|
      if !user_id_to_picks_map.has_key?(pick.user_id)
        user_id_to_picks_map[pick.user_id] = []
      end
      user_id_to_picks_map[pick.user_id] << pick
    }
    return user_id_to_picks_map
  end

  # map of stat_id to an array of chef ids
  def build_stat_id_to_chef_ids_map(chefstats)
    stat_id_to_chef_map = {}
    chefstats.each { |chefstat|
      if !stat_id_to_chef_map.has_key?(chefstat.stat_id)
        stat_id_to_chef_map[chefstat.stat_id] = []
      end
      stat_id_to_chef_map[chefstat.stat_id] << chefstat.chef_id
    }
    return stat_id_to_chef_map
  end

  # map of chefstat identifier to the corresponding chefstat
  def build_chefstat_id_to_chefstat_map(chefstats)
    chefstat_id_to_chefstat_map = {}
    chefstats.each { |chefstat|
      chefstat_id_to_chefstat_map[chefstat.my_identifier] = chefstat
    }
    return chefstat_id_to_chefstat_map
  end

  def build_stat_id_to_stat_map(stats)
    stat_id_to_stat_map = {}
    stats.each { |stat|
      stat_id_to_stat_map[stat.id] = stat
    }
    return stat_id_to_stat_map
  end

  def build_stat_abbr_to_stat_map(stats)
    stat_abbr_to_stat_map = {}
    stats.each { |stat|
      stat_abbr_to_stat_map[stat.abbreviation] = stat
    }
    return stat_abbr_to_stat_map
  end

  def build_user_id_to_user_map(users)
    user_id_to_user_map = {}
    users.each { |user|
      user_id_to_user_map[user.id] = user
    }
    return user_id_to_user_map
  end
end
