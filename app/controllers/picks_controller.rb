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
    if @week
      @picks = Pick.includes(:chef, :user)
                   .where(week: @week.number)
                   .order(:number)
      @current_pick = current_pick(@picks)
      @my_pick = @current_pick && @current_pick.user_id == @user.id
      if @my_pick
        # filter out eliminated chefs
        filtered_chef_ids = Chef.joins(:chefstats)
                                  .where("chefstats.stat_id = " +
                                      Stat.find_by_abbreviation(Stat::ELIMINATED_ABBR).id.to_s)
                                  .collect {|chef| chef.id }

        # filter out chefs already selected this week for win & loss
        filtered_chef_ids += Pick.where(week: @week.number)
                                 .select("chef_id, count(chef_id)")
                                 .group(:chef_id)
                                 .collect { |h| h.chef_id if h.count.to_i > 1 }.compact

        # if i've already made a pick, filter out chefs who have already been selected for the
        # opposite result
        my_week_picks = Pick.where({ week: @week.number, user_id: @user.id })
                            .where("chef_id is not null")
        @result_to_pick = nil
        if my_week_picks.count == 1
          my_week_pick = my_week_picks.first
          @result_to_pick = my_week_pick.record.to_s == :win.to_s ? :loss.to_s : :win.to_s

          filtered_chef_ids += Pick.where({ week: @week.number, record: @result_to_pick })
                                   .select("chef_id")
                                   .collect {|p| p.chef_id }
        end

        @chefs = Chef.where("id not in (?)", filtered_chef_ids)
                     .order(:first_name, :last_name)
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
            picks = Pick.includes(:user, :chef)
                        .where(week: week)
                        .order(:number)
            current_pick = current_pick(picks)
            if current_pick.user_id != @user.id
              confirmation_message = "Error: It's not your turn to pick, dumdum!"
            elsif chef_result_picked(picks, params["chef_id"].to_i, params["record"])
              record = Pick::abbreviation_to_record(params["record"])
              confirmation_message =
                  "Error: That chef has already been selected to " +
                      (record == :win ? "win" : "lose") + ", dumdum!"
            elsif user_result_picked(picks, @user.id, params["record"])
              record = Pick::abbreviation_to_record(params["record"])
              confirmation_message =
                  "Error: You've already selected a " + (record == :win ? "winner" : "loser") +
                      ", dumdum!"
            else
              # update pick
              current_pick.chef_id = params["chef_id"].to_i
              current_pick.record = Pick::abbreviation_to_record(params["record"])
              current_pick.save

              # send updated weekly picks email
              UserMailer.weekly_pick(week, picks, current_pick(picks)).deliver

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

  # returns true if the specified chef has already been selected with the specified record
  def chef_result_picked(picks, chef_id, record_abbr)
    picks.each { |pick|
      return true if pick.chef_id == chef_id && pick.my_record_abbreviation == record_abbr
    }
    return false
  end

  # returns true if the specified user has already made a pick with the specified record
  def user_result_picked(picks, user_id, record_abbr)
    picks.each { |pick|
      return true if pick.user_id == user_id && pick.my_record_abbreviation == record_abbr
    }
    return false
  end
end
