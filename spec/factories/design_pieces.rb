FactoryBot.define do
  factory :design_piece do
    mosaic_design
    sequence(:position) { |n| n - 1 }
    color { [ "#1A1A1A", "#F2C9A0", "#3B82F6", "#FFFFFF" ] }
  end
end
