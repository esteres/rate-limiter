class Api::V1::UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
        render json:  { id: @user.id, username: @user.username  }, status: :created
    else
      render json:  {
        error: @user.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end
