module ChefsHelper

  def chef_pick(chef, league)
    @all_draft_picks.each { |draft_pick|
      if draft_pick.league.to_s == league.to_s && draft_pick.chef_id == chef.id
        return draft_pick
      end
    }
    return nil
  end

  def chef_user(chef, league)
    @all_draft_picks.each { |draft_pick|
      if draft_pick.league.to_s == league.to_s && draft_pick.chef_id == chef.id
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

  def chef_table
    chef_table = "<table class='" + ApplicationHelper::TABLE_CLASS + "'>
      <thead>
        <tr>
          <th rowspan=2 colspan=2 class='rightborderme'>" + sortable(:chef.to_s, "Chef") + "</th>
          <th colspan=3 class='rightborderme'>" + sortable(:poboy.to_s, "Po-Boy Draft") + "</th>
          <th colspan=3 class='rightborderme'>" + sortable(:beignet.to_s, "Beignet Draft") + "</th>
          <th rowspan=2 class='rightborderme'>" + sortable(:fantasy_points.to_s, "Fantasy Points") +
         "</th>
          <th rowspan=2>" + sortable(:week.to_s, "Week Eliminated") + "</th>
        </tr>
        <tr>
          <th class='rightborderme'>Team</th>
          <th class='rightborderme'>Round</th>
          <th class='rightborderme'>Pick</th>
          <th class='rightborderme'>Team</th>
          <th class='rightborderme'>Round</th>
          <th class='rightborderme'>Pick</th>
        </tr>
      </thead>"

    case @sort_column.to_s
      when :chef.to_s, :poboy.to_s, :beignet.to_s
        @draft_picks.each { |draft_pick|
          chef_table << chef_row(draft_pick.chef)
        }
      when :fantasy_points.to_s
        sorted_chef_points = @chef_id_to_points_map.sort_by { |k,v| v }
        sorted_chef_points = sorted_chef_points.reverse if @sort_direction == "desc"
        sorted_chef_points.each { |chef_id_points|
          chef_table << chef_row(@chef_id_to_chef_map[chef_id_points[0]], chef_id_points[1])
        }
      when :week.to_s
        sorted_weeks = @chef_id_to_elimweek_map.sort_by { |k,v| v }
        sorted_weeks = sorted_weeks.reverse if @sort_direction == "desc"
        sorted_weeks.each { |chef_id_week|
          chef_table << chef_row(@chef_id_to_chef_map[chef_id_week[0]], nil, chef_id_week[1])
        }
    end

    chef_table << "</table>"
    return chef_table.html_safe
  end

  def chef_row(chef, chef_points = nil, elimination_week = nil)
    elimination_week = @chef_id_to_elimweek_map[chef.id] if elimination_week.nil?
    chef_class = elimination_week && elimination_week > 0 ? "red-row" : ""
    chef_class << " bold-row" if chef.belongs_to_user(@user)
    chef_points = @chef_id_to_points_map[chef.id] if chef_points.nil?

    chef_row = "<tr class='" + chef_class + "'>
        <td>" + chef.small_img + "</td>
        <td class='rightborderme'>" + chef.link_to_page_with_full_name + "</td>"
    [:poboy, :beignet].each { |league|
      chef_row << "
        <td>" + chef_user(chef, league).link_to_page_with_first_name + "</td>
        <td>" + chef_pick(chef, league).round.to_s + "</td>
        <td class='rightborderme'>" + chef_pick(chef, league).pick.to_s + "</td>"
    }
    chef_row << "
        <td class='rightborderme'>" + chef_points.to_s + "</td>
        <td>" + (elimination_week && elimination_week > 0 ? elimination_week.to_s : "") + "</td>
      </tr>"
    return chef_row
  end
end
