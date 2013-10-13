module StatsHelper

  def score_breakdown_tables
    score_html = ""
    @users.each { |user|
      score_html << "<h5>" + user.full_name + "</h5>"
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
          	stats = @chef_id_to_stat_id_map.has_key?(chef.id) ?
          	    @chef_id_to_stat_id_map[chef.id][week] : nil
          	stat_total_points = stat_total(stats)
            score_html << "<td class='leftborderme'>" + (stats ? stats.join(",") : "") + "</td>
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
     
      # TODO weekly picks

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

  def stat_total(stats)
    total = 0
    return total if !stats

    stats.each { |stat|
      total += stat.points
    }
    return total
  end
end
