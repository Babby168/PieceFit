# 取り直し用
# seed 全体（ストレッチ再投入）を待たずに、デモユーザーだけ初期化出来るようにする
# 実行: bin/rails demo:reset_user
namespace :demo do
  desc "ピッチ録画用デモユーザーを初期状態に戻す"
  task reset_user: :environment do
    DemoUserSeeder.call
    puts "デモユーザーを初期化しました: #{DemoUserSeeder::EMAIL}"
  end
end
