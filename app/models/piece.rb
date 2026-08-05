class Piece < ApplicationRecord
  belongs_to :mosaic_art

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }, uniqueness: { scope: :mosaic_art_id }

  # 獲得済みのピースを取得
  scope :acquired, -> { where.not(acquired_at: nil) }
  # 未獲得のピースを取得
  scope :unacquired, -> { where(acquired_at: nil) }
  # 指定した日時に獲得したピースを取得
  scope :acquired_on, ->(date) {
    where(acquired_at: date.in_time_zone.all_day)
  }

  # 獲得済みかどうかを判定
  def acquired?
    acquired_at.present?
  end
end
