class DraftPicksController < ApplicationController
  # GET /draft_picks
  # GET /draft_picks.json
  def index
    @draft_picks = DraftPick.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @draft_picks }
    end
  end

  # GET /draft_picks/1
  # GET /draft_picks/1.json
  def show
    @draft_pick = DraftPick.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @draft_pick }
    end
  end

  # GET /draft_picks/new
  # GET /draft_picks/new.json
  def new
    @draft_pick = DraftPick.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @draft_pick }
    end
  end

  # GET /draft_picks/1/edit
  def edit
    @draft_pick = DraftPick.find(params[:id])
  end

  # POST /draft_picks
  # POST /draft_picks.json
  def create
    @draft_pick = DraftPick.new(params[:draft_pick])

    respond_to do |format|
      if @draft_pick.save
        format.html { redirect_to @draft_pick, notice: 'Draft pick was successfully created.' }
        format.json { render json: @draft_pick, status: :created, location: @draft_pick }
      else
        format.html { render action: "new" }
        format.json { render json: @draft_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /draft_picks/1
  # PUT /draft_picks/1.json
  def update
    @draft_pick = DraftPick.find(params[:id])

    respond_to do |format|
      if @draft_pick.update_attributes(params[:draft_pick])
        format.html { redirect_to @draft_pick, notice: 'Draft pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @draft_pick.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /draft_picks/1
  # DELETE /draft_picks/1.json
  def destroy
    @draft_pick = DraftPick.find(params[:id])
    @draft_pick.destroy

    respond_to do |format|
      format.html { redirect_to draft_picks_url }
      format.json { head :no_content }
    end
  end
end
