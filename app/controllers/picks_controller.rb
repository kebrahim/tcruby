class PicksController < ApplicationController
  
  # GET /picks
  def index
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    @current_week = Pick.maximum(:week)
    @selected_week = @current_week
  end

  # GET /picks/week/:number
  def picks_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    @current_week = Pick.maximum(:week)
    @selected_week = params[:number].to_i
    render "index"
  end

  # GET /ajax/picks/week/:number
  def ajax_picks_week
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    # only let user see weeks that have completed
    @week = Week.find_by_number(params[:number].to_i)
    if @week && DateTime.now > @week.start_time
      @picks = Pick.includes(:chef, :user)
                   .where(week: @week.number)
                   .order(:number)
    end
    render :layout => "ajax"
  end

  # POST /picks/week/:number
  def update_picks
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end
    week = params[:number].to_i
    confirmation_message = ""
    if params["updatepicks"]
      # TODO
    end

    redirect_to "/picks/week/" + week.to_s, notice: confirmation_message
  end
end
