class DesignPiece < ApplicationRecord
  belongs_to :mosaic_design

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }, uniqueness: { scope: :mosaic_design_id }
  validates :color, presence: true
  validate :color_format

  private

  def color_format
    return if color.blank?
    if color.size != 4
      errors.add(:color, "は4色（左上・右上・左下・右下）である必要があります")
    end
    unless color.all? { |c| c.match?(/\A#[0-9A-Fa-f]{6}\z/) }
      errors.add(:color, "はHEXカラーコード形式である必要があります")
    end
  end
end
