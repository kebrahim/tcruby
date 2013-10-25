module StatsHelper

  def score_breakdown_tables
    score_html = ""
    @user_id_to_points_chefs_map.sort_by { |k,v| v["points"] }.reverse.each { |user_points|
      user = @user_id_to_users_map[user_points[0]]
      score_html << "<h5><a href='teams/" + user.id.to_s + "'>" + user.full_name + "</a> (" + 
          user_points[1]["points"].to_s + ")</h5>"
      score_html << "<table class='" + ApplicationHelper::TABLE_SMALL_CLASS + "'>
                       <thead><tr>
                         <th colspan=2>Chef</th>"
      if @max_week
        1.upto(@max_week) { |week|
          score_html << "<th colspan=2 class='leftborderme'>Week " + week.to_s + "</th>"
        }
      end
      score_html << "    <th class='leftborderme'>Total Points</th>
                       </tr></thead>"
       
      # chefs
      weekly_points = {}
      total_points = 0
      user.chefs.each { |chef|
        score_html << "<tr>
                         <td>pic</td><td>" + chef.full_name + "</td>"
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
            score_html << "<td class='leftborderme'>" + stat_names.join(",") + "</td>
                           <td>" + stat_total_points.to_s + "</td>"

          	chef_points += stat_total_points
            if !weekly_points.has_key?(week)
              weekly_points[week] = 0
            end
            weekly_points[week] += stat_total_points
            total_points += stat_total_points
          }
        end
        score_html << "  <td class='leftborderme'>" + chef_points.to_s + "</td>
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
          score_html << "<td class='leftborderme'>" + pick.chef.first_name + "</td>
                         <td>" + pick.points.to_s + "</td>"

          # update point totals
          total_win_bonus_points += pick.points
          weekly_points[week] += pick.points
          total_points += pick.points
        }
      end
      score_html << "  <td class='leftborderme'>" + total_win_bonus_points.to_s + "</td>
                     </tr>
                     <tr>
                       <td colspan=2>Losing Chef Bonus</td>"
      total_loss_bonus_points = 0
      if @max_week
        1.upto(@max_week) { |week|
          # show pick & points
          pick = @user_week_record_to_picks_map[Pick::user_week_record_id(user.id, week, :loss)]
          score_html << "<td class='leftborderme'>" + pick.chef.first_name + "</td>
                         <td>" + pick.points.to_s + "</td>"

          # update point totals
          total_loss_bonus_points += pick.points
          weekly_points[week] += pick.points
          total_points += pick.points
        }
      end
      score_html << "  <td class='leftborderme'>" + total_loss_bonus_points.to_s + "</td>
                     </tr>"

      # totals
      score_html << "<tr class='topborderme'><td colspan=2>Total</td>"
      if @max_week
        1.upto(@max_week) { |week|
          score_html << "<td colspan=2 class='leftborderme'>" + weekly_points[week].to_s + "</td>"
        }
      end
      score_html << "    <td class='leftborderme'>" + total_points.to_s + "</td>
                       </tr>
                     </table>"
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
end
