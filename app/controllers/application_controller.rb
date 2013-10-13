class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  helper_method :current_user

  private

  # returns the current logged-in user
  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end

  # logs the current user out of the system
  def logout_user
    cookies.delete(:auth_token)
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
