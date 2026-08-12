class PasswordChangesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # 現在のパスワードが正しく、新しいパスワードも有効な場合は更新して完了画面にリダイレクト
    if @user.update_with_password(password_params)
      # パスワード変更によってセッションが無効化されるのを防ぎ、ログイン状態を保つ
      bypass_sign_in(@user)
      redirect_to password_change_complete_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def complete
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
