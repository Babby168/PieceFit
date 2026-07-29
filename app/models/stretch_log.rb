class StretchLog < ApplicationRecord
  belongs_to :user
  belongs_to :stretch

  validates :performed_at, presence: true
end
