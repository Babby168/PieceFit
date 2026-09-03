FactoryBot.define do
  factory :stretch_step do
    stretch
    sequence(:step_number) { |n| n }
    image_path { "stretches/neck/neck_01/neck_1-1.png" }
    description { Faker::Lorem.sentence }
  end
end
