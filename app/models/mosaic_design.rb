class MosaicDesign < ApplicationRecord
  belongs_to :mosaic_series, optional: true
  has_many :design_pieces, dependent: :destroy

  scope :in_collection, -> { where.not(mosaic_series_id: nil) }

  validates :name, presence: true, uniqueness: true
  validates :area_size_x, :area_size_y, presence: true, numericality: { greater_than: 0 }
  validates :collection_position,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :mosaic_series_id },
            allow_nil: true
end
