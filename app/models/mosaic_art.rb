class MosaicArt < ApplicationRecord
  belongs_to :user
  belongs_to :mosaic_design
  has_many :pieces, dependent: :destroy
end
