class UserMailer < ActionMailer::Base
  default from: "noreply@rotiss.com"

  # sends an email to all non-demo users showing all the picks during the specified week
  def weekly_pick(week, picks, current_pick)
    @week = week
    @picks = picks
    @current_pick = current_pick

    # send email to all non-demo users
    mail :to => User.where("role != 'demo'").pluck(:email),
         :subject => "Top Chef Rotiss - Week " + week.to_s + " Picks"
  end

  # sends an email to all non-demo users showing the scoring summary for the specified week, the
  # updated standings and the weekly picks for next week.
  def scoring_summary(week, user_id_to_points_chefs_map, user_id_to_users_map)
    @week = week
    @next_week = week + 1

    @chefs = Chef.includes(:chefstats, :stats)
                 .where("chefstats.week = " + week.to_s)
                 .order(:first_name, :last_name, "stats.abbreviation")
 
    @picks = Pick.includes(:user, :chef)
                 .where(week: @week)
                 .where("points != 0")
                 .order(:number)

    @user_id_to_points_chefs_map = user_id_to_points_chefs_map
    @user_id_to_users_map = user_id_to_users_map

    @next_week_picks = Pick.includes(:user)
                           .where(week: @next_week)
                           .order(:number)
    
    # send email to all non-demo users
    mail :to => User.where("role != 'demo'").pluck(:email),
         :subject => "Top Chef Rotiss - Week " + week.to_s + " Scoring Summary"
  end
end
