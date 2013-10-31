module ChefsHelper

  def chef_pick(chef, league)
    @chef_id_to_picks_map[chef.id].each { |draft_pick|
      if draft_pick.league.to_s == league.to_s
        return "Rd: " + draft_pick.round.to_s + ", Pk: " + draft_pick.pick.to_s
      end
    }
    return nil
  end

  def chef_user(chef, league)
    @chef_id_to_picks_map[chef.id].each { |draft_pick|
      if draft_pick.league.to_s == league.to_s
        return draft_pick.user
      end
    }
    return nil
  end

  def chefstats_to_report_names(stat_type, week)
    if @stattype_week_to_chefstats_map[stat_type].has_key?(week)
      return @stattype_week_to_chefstats_map[stat_type][week].collect { |chefstat|
          chefstat.stat.report_name }.join(", ")
    end
    return ""
  end

  def chefstats_to_points(week)
    points = 0
    Stat::ALL_TYPES_ARRAY.each { |stat_type|
      if @stattype_week_to_chefstats_map[stat_type].has_key?(week)
        @stattype_week_to_chefstats_map[stat_type][week].each { |chefstat|
          points += chefstat.stat.points
        }
      end
    }
    return points
  end

  def chefstat_class(chefstats, win_stat_abbr, lose_stat_abbr)
    if chefstats
      chefstats.each { |chefstat|
        if chefstat.stat.abbreviation == win_stat_abbr
          return "green-cell"
        elsif chefstat.stat.abbreviation == lose_stat_abbr
          return "red-cell"
        end
      }
    end
    return ""
  end
end
