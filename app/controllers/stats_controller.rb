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

  # GET /scores
  def scores
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @current_week = current_week_number
    @selected_week = @current_week    
  end

  # GET /scores/week/:number
  def scores_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @current_week = current_week_number
    @selected_week = params[:number].to_i
    render "scores"
  end

  # GET /ajax/scores/week/:number
  def ajax_scores_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    # only let user see weeks that have completed
    @week = Week.where(number: params[:number].to_i).first
    if @week && DateTime.now > @week.start_time
      @chefs = Chef.order(:first_name)
    end
    render :layout => "ajax"
  end
end
