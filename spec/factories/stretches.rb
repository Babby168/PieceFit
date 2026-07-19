FactoryBot.define do
  factory :stretch do
    name { Faker::Lorem.sentence(word_count: 3) }
    body_part { :neck }
    description { Faker::Lorem.paragraph }
    point { Faker::Lorem.sentence }
    key_visual_path { "stretches/key_visual/neck_kv.png" }

    trait :shoulder do
      body_part { :shoulder }
      key_visual_path { "stretches/key_visual/shoulder_kv.png" }
    end

    trait :waist do
      body_part { :waist }
      key_visual_path { "stretches/key_visual/waist_kv.png" }
    end
  end
end
