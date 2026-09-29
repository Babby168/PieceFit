class MosaicSeries < ApplicationRecord
  has_many :mosaic_designs, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }, uniqueness: true
end
