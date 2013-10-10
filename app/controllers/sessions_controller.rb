class SessionsController < ApplicationController
  def new
  	if cookies[:auth_token]
      user = User.find_by_auth_token(cookies[:auth_token])
    end
    if !user.nil?
      redirect_to scoreboard_url
    end
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token  
      end
      redirect_to scoreboard_url
    else
      error_message = !user ? "Error: Invalid email or password" :
          "Error: Account not confirmed yet; please check your email!"
      redirect_to root_url, notice: error_message
    end
  end

  def destroy
    logout_user
    redirect_to root_url
  end
end
