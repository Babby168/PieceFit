FactoryBot.define do
  factory :stretch_step do
    stretch
    sequence(:step_number) { |n| n }
    image_path { "stretches/steps/step_#{step_number}.png" }
    description { Faker::Lorem.sentence }
  end
end
