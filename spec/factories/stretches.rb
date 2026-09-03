FactoryBot.define do
  factory :stretch do
    name { Faker::Lorem.sentence(word_count: 3) }
    body_part { :neck }
    description { Faker::Lorem.paragraph }
    point { Faker::Lorem.sentence }
    key_visual_path { "stretches/key_visual/neck/neck_kv_1.png" }

    trait :shoulder do
      body_part { :shoulder }
      key_visual_path { "stretches/key_visual/shoulder/shoulder_kv_1.png" }
    end

    trait :waist do
      body_part { :waist }
      key_visual_path { "stretches/key_visual/waist/waist_kv_1.png" }
    end
  end
end
