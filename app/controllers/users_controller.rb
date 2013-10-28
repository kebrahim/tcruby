class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    elsif @user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @current_user = current_user
    if @current_user.nil?
      redirect_to root_url
      return
    elsif @current_user.is_admin == false
      redirect_to dashboard_url
      return
    end

    @admin_function = true
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    redirect_url = params.has_key?("admin_fxn") ? ('/users/' + @user.id.to_s + '/edit') : '/profile'

    if params["commit"]
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to redirect_url, notice: 'User successfully updated.' }
          format.json { head :no_content }
        else
          format.html {
            if params.has_key?("admin_fxn")
              @admin_function = true
              @current_user = current_user
              render action: 'edit'
            else
              @admin_function = false
              @current_user = current_user
              render action: 'profile'
            end
          }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to redirect_url
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /dashboard
  def dashboard
    @user = current_user
    if @user.nil?
      redirect_to root_url
      return
    end

    # load data
    users = User.includes(:chefs).where("role != 'demo'")
    chefstats = Chefstat.all
    stats = Stat.all
    @score_week_number = Chefstat.maximum(:week)
    @pick_week_number = Pick.maximum(:week)
    @picks = Pick.includes(:chef, :user)
                 .where(week: @pick_week_number)
                 .order(:number)
    all_picks = Pick.all

    # convert data to maps
    @user_id_to_points_chefs_map = build_user_id_to_points_chefs_map(
        users, chefstats, stats, all_picks)
    @user_id_to_users_map = build_user_id_to_user_map(users)

    @current_pick = current_pick(@picks)
    @my_pick = @current_pick && @current_pick.user_id == @user.id
  end

  # GET /profile
  def profile
    @admin_function = false
    @current_user = current_user
    @user = @current_user
    if @user.nil? || @user.is_demo_user
      redirect_to root_url
      return
    end
  end

  # GET /teams
  def teams
    @current_user = current_user
    if @current_user.nil?
      redirect_to root_url
      return
    end
    @users = User.where("role != 'demo'").order(:first_name, :last_name)
    @selected_user = @current_user
  end

  # GET /teams/:user_id
  def team
    @current_user = current_user
    if @current_user.nil?
      redirect_to root_url
      return
    end
    @users = User.where("role != 'demo'").order(:first_name, :last_name)
    @selected_user = User.find(params[:user_id].to_i)
    render "teams"
  end

  # GET /ajax/teams/:user_id
  def ajax_team
    @current_user = current_user
    if @current_user.nil?
      redirect_to root_url
      return
    end

    # load data from db
    @selected_user = User.find(params[:user_id].to_i)
    @chefs = @selected_user.chefs
    chef_ids = @chefs.collect{|chef| chef.id}
    @draft_picks = DraftPick.includes(:chef)
                            .where("chef_id in (?)", chef_ids)
                            .where(user_id: @selected_user.id)
                            .order(:round)
    @picks = Pick.includes(:chef)
                 .where("chef_id is not null")
                 .where(user_id: @selected_user.id)
                 .order(:week, "record DESC")
    user_chefstats = Chefstat.where("chef_id in (?)", chef_ids)
    stats = Stat.all

    # convert data to maps
    @chef_id_to_points_map =
        build_chef_id_to_points_map(user_chefstats, build_stat_id_to_stat_map(stats))
    @chef_id_to_chefstats_map = build_chef_id_to_chefstats_map(user_chefstats)
    
    render :layout => "ajax"
  end
end
