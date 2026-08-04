FactoryBot.define do
  factory :piece do
    mosaic_art
    sequence(:position) { |n| n - 1 }
    acquired_at { nil }
    is_bonus { false }
  end
end
