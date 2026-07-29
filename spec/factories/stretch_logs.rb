FactoryBot.define do
  factory :stretch_log do
    user
    stretch
    performed_at { Time.current }
  end
end
