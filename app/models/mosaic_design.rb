class MosaicDesign < ApplicationRecord
  has_many :design_pieces, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :area_size_x, :area_size_y, presence: true, numericality: { greater_than: 0}
end
