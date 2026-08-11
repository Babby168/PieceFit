class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stretch_logs, dependent: :destroy
  has_many :mosaic_arts, dependent: :destroy

  validates :nickname, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :password_confirmation, presence: true, on: :create


  EMAIL_CHANGE_TOKEN_EXPIRATION = 24.hours

  # 仮メールアドレスのバリデーション（必須 / アドレス変更時）
  validates :unconfirmed_email, presence: true, on: :email_change
  # 仮メールアドレスのバリデーション（形式 / アドレス変更時 / 空文字を許可）
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :email_change, allow_blank: true
  # 仮メールアドレスのバリデーション（一意性 / アドレス変更時）
  validate :unconfirmed_email_must_be_unique, on: :email_change, if: -> { unconfirmed_email.present? }
  # 仮メールアドレスのバリデーション（現在のメールアドレスと異なる / アドレス変更時）
  validate :unconfirmed_email_must_differ_from_current, on: :email_change, if: -> { unconfirmed_email.present? }


  def current_streak_days
    dates = stretch_logs
              .where(performed_at: 90.days.ago.beginning_of_day..Time.current)
              .pluck(:performed_at)
              .map { |t| t.in_time_zone.to_date }
              .uniq
              .sort
              .reverse

    # 今日のストレッチログがない場合は0を返す
    return 0 unless dates.first == Time.zone.today

    count = 0
    # 今日の日付を期待する日付として設定
    expected = Time.zone.today
    # ストレッチログの日付を順番に確認
    dates.each do |date|
      # 期待する日付と一致しない場合はループを終了
      break unless date == expected

      # 連続日数をカウント
      count += 1
      # 期待する日付を1日前に更新
      expected -= 1
    end
    count
  end

  # メールアドレス変更トークンを生成して保存
  def generate_email_change_token!
    update_columns(
      unconfirmed_email: unconfirmed_email,
      email_change_token: SecureRandom.urlsafe_base64,
      email_change_token_sent_at: Time.current
    )
  end

  # メールアドレス変更トークンが期限切れかどうかを判定
  def email_change_token_expired?
    email_change_token_sent_at.nil? || email_change_token_sent_at < EMAIL_CHANGE_TOKEN_EXPIRATION.ago
  end

  # メールアドレス変更を確認
  def confirm_email_change!
    update!(
      email: unconfirmed_email,
      unconfirmed_email: nil,
      email_change_token: nil,
      email_change_token_sent_at: nil
    )
  end
  
  private

  # 仮メールアドレスが一意かを確認
  def unconfirmed_email_must_be_unique
    errors.add(:unconfirmed_email, :taken) if User.where(email: unconfirmed_email).where.not(id: id).exists?
  end

  # 仮メールアドレスが現在のメールアドレスと異なるかを確認
  def unconfirmed_email_must_differ_from_current
    errors.add(:unconfirmed_email, :unchanged) if unconfirmed_email == email
  end
end
