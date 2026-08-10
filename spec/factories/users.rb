FactoryBot.define do
  factory :user do
    nickname { Faker::Lorem.characters(number: 8) }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6) }
    password_confirmation { password }
  end
end
