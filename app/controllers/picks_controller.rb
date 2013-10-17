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
      @current_pick = current_pick(@picks)
      @my_pick = @current_pick && @current_pick.user_id == @user.id
      if @my_pick
        # filter out eliminated chefs
        eliminated_chef_ids = Chef.joins(:chefstats)
                                  .where("chefstats.stat_id = " +
                                      Stat.find_by_abbreviation(Stat::ELIMINATED_ABBR).id.to_s)
                                  .collect {|chef| chef.id }
        @chefs = Chef.where("id not in (?)", eliminated_chef_ids)
                     .order(:last_name, :first_name)
      end
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
      # update user's pick
      Pick.transaction do
        begin
          if params["chef_id"].nil? || params["chef_id"] == "0"
            confirmation_message = "Error: You have to pick a chef, dumdum!"
          elsif params["record"].nil? || params["record"] == "0"
            confirmation_message = "Error: You have to pick a result, dumdum!"
          else
            picks = Pick.where(week: week)
                        .order(:number)
            current_pick = current_pick(picks)
            if current_pick.user_id != @user.id
              confirmation_message = "Error: It's not your turn to pick, dumdum!"
            elsif chef_result_picked(picks, params["chef_id"].to_i, params["record"])
              confirmation_message =
                  "Error: That chef-result pair has already been selected, dumdum!"
            else
              # update pick
              current_pick.chef_id = params["chef_id"].to_i
              current_pick.record = Pick::abbreviation_to_record(params["record"])
              current_pick.save

              # TODO send email 
              confirmation_message = "Congratulations! You successfully made your weekly pick!"
            end
          end
        rescue Exception => e
          confirmation_message = "Error: Problem occurred while selecting pick: " + e.message
        end
      end
    end

    redirect_to "/picks/week/" + week.to_s, notice: confirmation_message
  end

  def chef_result_picked(picks, chef_id, record_abbr)
    picks.each { |pick|
      return true if pick.chef_id == chef_id && pick.my_record_abbreviation == record_abbr
    }
    return false
  end
end
