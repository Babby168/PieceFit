FactoryBot.define do
  factory :mosaic_series do
    sequence(:name) { |n| "シリーズ#{n}" }
    sequence(:position)
  end
end
