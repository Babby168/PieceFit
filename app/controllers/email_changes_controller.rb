class EmailChangesController < ApplicationController
  # ログインしていない場合は確認画面にリダイレクト
  before_action :authenticate_user!, except: [ :confirm ]
  # ユーザーを取得
  before_action :set_user, only: %i[ edit update complete ]

  def edit
  end

  def update
    @user.unconfirmed_email = email_params[:unconfirmed_email]

    if @user.valid?(:email_change)
      @user.generate_email_change_token!
      EmailChangeMailer.confirmation_instructions(@user).deliver_later
      redirect_to email_change_complete_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def complete
  end

  def confirm
    user = User.find_by(email_change_token: params[:token])

    if user.nil? || user.email_change_token_expired?
      return redirect_to edit_email_change_path, alert: "リンクの有効期限が切れているか、無効なリンクです。もう一度お試しください。"
    end

    user.confirm_email_change!
    redirect_to email_change_confirmed_path
  end

  def confirmed
  end

  private

  def set_user
    @user = current_user
  end

  def email_params
    params.require(:user).permit(:unconfirmed_email)
  end
end
