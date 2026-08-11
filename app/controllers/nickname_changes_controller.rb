class NicknameChangesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # ニックネームが変更されていない場合はエラーを追加して編集画面を表示
    if nickname_unchanged?
      @user.errors.add(:nickname, :unchanged)
      return render :edit, status: :unprocessable_content
    end

    # ニックネームが変更されている場合は更新して完了画面にリダイレクト
    if @user.update(nickname_params)
      redirect_to nickname_change_complete_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def complete
  end

  private

  # ニックネームが変更されていないかを確認
  def nickname_unchanged?
    # ニックネームが入力されていて、かつ入力されたニックネームが変更前のニックネームと一致している場合はtrueを返す
    nickname_params[:nickname].present? && nickname_params[:nickname] == @user.nickname
  end

  # ニックネームのパラメータを取得
  def nickname_params
    params.require(:user).permit(:nickname)
  end
end
