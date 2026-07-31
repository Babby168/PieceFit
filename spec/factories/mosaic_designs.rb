FactoryBot.define do
  factory :mosaic_design do
    sequence(:name) { |n| "モザイクデザイン#{n}" }
    area_size_x { 10 }
    area_size_y { 9 }
  end
end
