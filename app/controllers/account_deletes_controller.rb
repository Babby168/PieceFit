class AccountDeletesController < ApplicationController
  # ログインしていない場合はログインページにリダイレクト
  before_action :authenticate_user!, except: [ :complete ]

  def show
  end

  def destroy
    # ユーザーを削除
    current_user.destroy
    # サインアウト
    sign_out current_user
    # アカウント削除完了ページにリダイレクト
    redirect_to account_delete_complete_path
  end

  def complete
  end
end
