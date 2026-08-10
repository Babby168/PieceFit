class NicknameChangesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(nickname_params)
      redirect_to nickname_change_complete_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def complete
  end

  private

  def nickname_params
    params.require(:user).permit(:nickname)
  end
end
