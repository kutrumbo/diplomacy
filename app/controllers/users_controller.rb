class UsersController < ApplicationController
  def new
  end

  def create
    user = User.new(params.permit(:name, :email, :password))
    if user && user.save
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in!"
    else
      flash.now[:alert] = "Information is invalid"
      render "new"
    end
  end
end
