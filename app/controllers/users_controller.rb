class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update_games, :edit, :update, :destroy]
  UPDATES_TIMEFRAME = 15.days

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if @user.updated_at > Time.now + UPDATES_TIMEFRAME || @user.games.nil?
      @user.update_collection
    end
    @games = @user.games

    @games.each do |g|
      Game.create_from_bgg(g.bgg_id) if g.name.nil?
    end
  end

  def search
    bgg = BggApi.new
    user = bgg.user(name: params[:q])
    redirect_to root_path and return if user["id"].empty?

    @user = User.find_or_create_by(name: params[:q])
    redirect_to user_path(@user)
  end

  def update_games
    @user.update_collection
    redirect_to @user
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end
end
