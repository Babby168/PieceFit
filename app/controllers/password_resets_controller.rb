class PasswordResetsController < ApplicationController
  def edit
    @user = User.new
  end

  def update
    email = email_params[:email].to_s.strip
    @user = User.new(email: email)

    if email.blank?
      @user.errors.add(:email, :blank)
      return render :edit, status: :unprocessable_content
    end

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      @user.errors.add(:email, :invalid)
      return render :edit, status: :unprocessable_content
    end

    user = User.find_by(email: email)
    if user
      raw_token = user.generate_reset_password_token!
      PasswordResetMailer.reset_instructions(user, raw_token).deliver_later
    end

    redirect_to password_reset_complete_path
  end

  def complete
  end

  def confirm
    @user = User.with_reset_password_token(params[:token])

    if @user.nil? || !@user.reset_password_period_valid?
      redirect_to edit_password_reset_path, alert: "リンクの有効期限が切れているか、無効なリンクです。もう一度お試しください。"
    end
  end

  def reset
    @user = User.with_reset_password_token(params[:token])

    if @user.nil? || !@user.reset_password_period_valid?
      return redirect_to edit_password_reset_path,
                         alert: "リンクの有効期限が切れているか、無効なリンクです。もう一度お試しください。"
    end

    if password_unchanged?
      @user.errors.add(:password, :unchanged)
      return render :confirm, status: :unprocessable_content
    end

    if @user.reset_password(password_params[:password],
                            password_params[:password_confirmation])
       redirect_to password_reset_confirmed_path
    else
      render :confirm, status: :unprocessable_content
    end
  end

  def confirmed
  end

  private

  def email_params
    params.require(:user).permit(:email)
  end

  def password_unchanged?
    password_params[:password].present? && @user.valid_password?(password_params[:password])
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
