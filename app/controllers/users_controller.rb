class UsersController < ApplicationController
  def new
  end

  def create
    user = User.new(params.permit(:name, :email, :password))
    if user && user.save
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Information is invalid"
      render "new"
    end
  end

  def show
    raise 'Must be logged in' if current_user.nil?
    @user = current_user
  end

  def update
    @user = current_user
    updated_params = params.require(:user).permit(:name, :password)
    @user.name = updated_params[:name]
    @user.password = updated_params[:password] if updated_params[:password].present?
    @user.save!
    redirect_to user_path, notice: 'Settings updated'
  end
end
