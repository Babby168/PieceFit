require "rails_helper"

RSpec.describe DemoUserSeeder, type: :service do
  def create_design!(name)
    design = create(:mosaic_design, name: name, area_size_x: 2, area_size_y: 2)
    4.times { |i| create(:design_piece, mosaic_design: design, position: i) }
    design
  end

  before do
    create_design!(DemoUserSeeder::IN_PROGRESS_DESIGN_NAME)
    DemoUserSeeder::COMPLETED_DESIGN_NAMES.each { |name| create_design!(name) }
    create(:stretch)
    create(:stretch, :shoulder)
    create(:stretch, :waist)
  end

  it "進行中アートは末尾2ピースだけ未獲得であること" do
    user = described_class.call
    art = user.mosaic_arts.in_progress.last

    expect(art.mosaic_design.name).to eq("ロボらんてくん")
    expect(art.pieces.acquired.count).to eq(2)
    expect(art.pieces.unacquired.order(:position).pluck(:position)).to eq([ 2, 3 ])
    expect(art.pieces.acquired.first.acquired_at.to_date).not_to eq(Time.zone.today)
  end

  it "コレクション用の完成アートが2件だけあること" do
    user = described_class.call
    completed = user.mosaic_arts.completed

    expect(completed.count).to eq(2)
    expect(completed.map { |art| art.mosaic_design.name }).to match_array(%w[ドクター シェフ])
    expect(completed).to all(satisfy { |art| art.pieces.unacquired.none? })
  end

  it "連続日数が今日を含み、3の倍数ではないこと" do
    user = described_class.call

    expect(user.current_streak_days).to eq(DemoUserSeeder::STREAK_DAYS)
    expect(DemoUserSeeder::STREAK_DAYS % StreakBonusService::STREAK_THRESHOLD).not_to eq(0)
  end

  it "2回実行してもレコードが増えないこと" do
    described_class.call

    expect { described_class.call }.not_to change(User, :count)
    user = User.find_by!(email: DemoUserSeeder::EMAIL)
    expect(user.mosaic_arts.count).to eq(3)
  end
end
