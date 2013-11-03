module StatsHelper

  def score_breakdown_tables
    score_html = ""
    @user_id_to_points_chefs_map.sort_by { |k,v| v["points"] }.reverse.each { |user_points|
      user = @user_id_to_users_map[user_points[0]]
      score_html << "<h5>"
      # TDOO replace with expand/collapse buttons
      score_html << "<button type='button'
                             class='btn btn-link collapse-btn'
                             data-toggle='collapse'
                             data-target='#user-collapse" + user.id.to_s + "'>
                       <i class='icon-" + (@user.id == user.id ? "minus" : "plus") + "'></i>
                     </button>"
      score_html << user.link_to_page_with_full_name + " (" + user_points[1]["points"].to_s + ")"
      score_html << "</h5>"
      score_html << "<div id='user-collapse" + user.id.to_s + "' 
                          class='collapse user-collapse " +
                              (@user.id == user.id ? "in" : "out") + "'>"
      score_html << "<table class='" + ApplicationHelper::TABLE_SMALL_CLASS + "'>
                       <thead><tr>
                         <th colspan=2>Chef</th>"
      if @max_week
        1.upto(@max_week) { |week|
          score_html << "<th colspan=2 class='leftborderme'>
                           <a href='/scoreboard/week/" + week.to_s + "'>Week " + week.to_s + "</a>
                         </th>"
        }
      end
      score_html << "    <th class='leftborderme'>Total</th>
                       </tr></thead>"
       
      # chefs
      weekly_points = {}
      total_points = 0
      user.chefs.each { |chef|
        stat_class = chef_stat_class(@chef_id_to_stat_id_map[chef.id], @elimination_stat_id)
        score_html << "<tr>
                         <td class='" + stat_class + "'>" + chef.mini_img + "</td>
                         <td class='" + stat_class + "'>" + chef.link_to_page_with_full_name +
                         "</td>"
        chef_points = 0
        if @max_week
          1.upto(@max_week) { |week|
          	stat_ids = @chef_id_to_stat_id_map.has_key?(chef.id) ?
          	    @chef_id_to_stat_id_map[chef.id][week] : nil
          	stat_total_points = stat_total(stat_ids)
            stat_names = stat_ids.nil? ? [] :
                stat_ids.collect { |stat_id|
                  @stat_id_to_stat_map[stat_id].abbreviation
                }
            score_html << "<td class='leftborderme " + stat_class(stat_names) + "'>" +
                             stat_names.join(",") + "</td>
                           <td class='" + stat_class(stat_names) + "'>" +
                             stat_total_points.to_s + "</td>"

          	chef_points += stat_total_points
            if !weekly_points.has_key?(week)
              weekly_points[week] = 0
            end
            weekly_points[week] += stat_total_points
            total_points += stat_total_points
          }
        end
        score_html << "  <td class='leftborderme bold-cell'>" + chef_points.to_s + "</td>
                       </tr>"
      }
     
      # weekly picks
      score_html << "<tr class='topborderme'>
                       <td colspan=2>Winning Chef Bonus</td>"
      total_win_bonus_points = 0
      if @max_week
        1.upto(@max_week) { |week|
          # show pick & points
          pick = @user_week_record_to_picks_map[Pick::user_week_record_id(user.id, week, :win)]
          score_html << "<td class='leftborderme" + pick.cell_class + "'>" +
                           pick.chef.link_to_page_with_first_name +
                        "</td>
                         <td class='" + pick.cell_class + "'>" + pick.points.to_s + "</td>"

          # update point totals
          total_win_bonus_points += pick.points
          weekly_points[week] += pick.points
          total_points += pick.points
        }
      end
      score_html << "  <td class='leftborderme bold-cell'>" + total_win_bonus_points.to_s + "</td>
                     </tr>
                     <tr>
                       <td colspan=2>Losing Chef Bonus</td>"
      total_loss_bonus_points = 0
      if @max_week
        1.upto(@max_week) { |week|
          # show pick & points
          pick = @user_week_record_to_picks_map[Pick::user_week_record_id(user.id, week, :loss)]
          score_html << "<td class='leftborderme " + pick.cell_class + "'>" +
                           pick.chef.link_to_page_with_first_name +
                        "</td>
                         <td class='" + pick.cell_class + "'>" + pick.points.to_s + "</td>"

          # update point totals
          total_loss_bonus_points += pick.points
          weekly_points[week] += pick.points
          total_points += pick.points
        }
      end
      score_html << "  <td class='leftborderme bold-cell'>" + total_loss_bonus_points.to_s + "</td>
                     </tr>"

      # totals
      score_html << "<tr class='topborderme bold-row'><td colspan=2>Total</td>"
      if @max_week
        1.upto(@max_week) { |week|
          score_html << "<td colspan=2 class='leftborderme'>" + weekly_points[week].to_s + "</td>"
        }
      end
      score_html << "    <td class='leftborderme'>" + total_points.to_s + "</td>
                       </tr>
                     </table>
                   </div>"
    }
    return score_html.html_safe
  end

  def stat_total(stat_ids)
    total = 0
    return total if stat_ids.nil?

    stat_ids.each { |stat_id|
      total += @stat_id_to_stat_map[stat_id].points
    }
    return total
  end

  def stat_class(stat_names)
    if stat_names.include?(Stat::WINNER_ABBR) || stat_names.include?(Stat::TEAM_WINNER_ABBR)
      return "green-cell"
    elsif stat_names.include?(Stat::ELIMINATED_ABBR)
      return "red-cell"
    end
    return ""
  end

  def chef_stat_class(week_to_stat_ids, elimination_stat_id)
    if week_to_stat_ids
      week_to_stat_ids.each { |week, stat_ids|
        return "red-cell" if stat_ids.include?(elimination_stat_id)
      }
    end
    return ""
  end
end
