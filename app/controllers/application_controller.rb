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

  # map of chef_id to a map of week number to an array of stats
  def build_chef_id_to_stat_map(chefstats)
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

  def build_stat_id_to_stat_map(stats)
    stat_id_to_stat_map = {}
    stats.each { |stat|
      stat_id_to_stat_map[stat.id] = stat
    }
    return stat_id_to_stat_map
  end
end
