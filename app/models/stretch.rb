class Stretch < ApplicationRecord
  has_many :stretch_steps, -> { order(:step_number) }, dependent: :destroy
  has_many :stretch_logs, dependent: :destroy

  enum :body_part, {
    "neck" => 0,
    "shoulder" => 1,
    "waist" => 2
  }

  validates :name, presence: true
  validates :body_part, presence: true
end
