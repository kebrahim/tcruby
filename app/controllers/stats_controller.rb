class StatsController < ApplicationController

  # GET /scoreboard
  def scoreboard
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    @stats = Stat.order(:ordinal)
    @max_week = Chefstat.maximum(:week)

    # TODO sort users by total points
    @users = User.all
    @chef_id_to_stat_id_map = build_chef_id_to_stat_map(Chefstat.all)
    @stat_id_to_stat_map = build_stat_id_to_stat_map(@stats)
  end
end
