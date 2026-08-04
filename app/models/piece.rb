class Piece < ApplicationRecord
  belongs_to :mosaic_art

  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }, uniqueness: { scope: :mosaic_art_id }
end
