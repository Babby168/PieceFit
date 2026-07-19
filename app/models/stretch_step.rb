class StretchStep < ApplicationRecord
  belongs_to :stretch
  validates :step_number, presence: true, uniqueness: { scope: :stretch_id }
  validates :image_path, presence: true
  validates :description, presence: true
end
