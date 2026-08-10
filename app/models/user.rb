class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stretch_logs, dependent: :destroy
  has_many :mosaic_arts, dependent: :destroy

  validates :nickname, presence: true, uniqueness: true, length: { maximum: 10 }
  validates :password_confirmation, presence: true, on: :create

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
end
