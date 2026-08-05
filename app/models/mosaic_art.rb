class MosaicArt < ApplicationRecord
  belongs_to :user
  belongs_to :mosaic_design
  has_many :pieces, dependent: :destroy

  # 進行中のモザイクアートを取得
  scope :in_progress, -> { where(completed_at: nil) }

  # 完成しているかどうかを判定
  def completed?
    completed_at.present?
  end
end
