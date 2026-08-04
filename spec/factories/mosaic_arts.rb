FactoryBot.define do
  factory :mosaic_art do
    user
    mosaic_design
    completed_at { nil }
  end
end
