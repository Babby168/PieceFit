# デモユーザーを作成するサービス
class DemoUserSeeder
  EMAIL = "demo@example.com"
  NICKNAME = "デモユーザー"
  IN_PROGRESS_DESIGN_NAME = "ロボらんてくん"
  COMPLETED_DESIGN_NAMES = [ "ドクター", "シェフ" ].freeze
  REMAINING_PIECES = 2
  STREAK_DAYS = 5 # 3の倍数にしない（ボーナスで1回で完成するのを防ぐ）

  # デモユーザーを作成する
  def self.call
    new.call
  end

  # デモユーザー内での環境を作成する
  def call
    user = find_or_create_user!
    reset_demo_data!(user)
    create_completed_arts!(user)
    create_in_progress_art!(user)
    create_stretch_logs!(user)
    user
  end

  private

  # デモユーザーのパスワードを取得する（環境変数から）
  def password
    ENV.fetch("DEMO_USER_PASSWORD", "password")
  end

  # デモユーザーを作成する（ユーザーが存在しない場合は作成する）
  def find_or_create_user!
    user = User.find_or_initialize_by(email: EMAIL) # 同じメールなら更新、無ければ新規作成。
    user.nickname = NICKNAME
    user.password = password
    user.password_confirmation = password
    user.save!
    user
  end

  # 取り消し用: このユーザーのモザイクとログだけ消す（他ユーザーは触らない）
  def reset_demo_data!(user)
    user.mosaic_arts.destroy_all # モザイクアートを全削除。（外部キー制約によりピースも削除される）
    user.stretch_logs.destroy_all
  end

  # 完成したモザイクを作成する
  def create_completed_arts!(user)
    COMPLETED_DESIGN_NAMES.each_with_index do |name, index|
      design = find_design!(name)
      art = user.mosaic_arts.create!(
        mosaic_design: design,
        completed_at: (index + 1).weeks.ago
      )
      insert_pieces!(art, acquired: true)
    end
  end

  # 進行中のモザイクを作成する
  def create_in_progress_art!(user)
    design = find_design!(IN_PROGRESS_DESIGN_NAME)
    art = user.mosaic_arts.create!(
      mosaic_design: design,
      completed_at: nil
    )
    insert_pieces!(art, acquired: :almost_done)
  end

  # acquired: true なら全獲得 / :almost_done なら末尾 REMAINING_PIECES だけ未獲得
  # ピースを一括で挿入する
  def insert_pieces!(art, acquired:)
    now = Time.current
    yesterday = 1.day.ago
    last_acquired_position = art.mosaic_design.design_pieces.maximum(:position).to_i - REMAINING_PIECES

    rows = art.mosaic_design.design_pieces.map do |design_piece|
      acquired_at =
        case acquired
        when true
          yesterday
        when :almost_done
          design_piece.position <= last_acquired_position ? yesterday : nil
        end

      {
        mosaic_art_id: art.id,
        position: design_piece.position,
        acquired_at: acquired_at,
        is_bonus: false,
        created_at: now,
        updated_at: now
      }
    end

    Piece.insert_all(rows) if rows.any? # insert_all ＝ 90ピース × 3作品でも1回のSQLで入れられる。 create! をループすると遅い
  end

  # ストレッチログを作成する
  def create_stretch_logs!(user)
    stretches = Stretch.order(:id).to_a
    return if stretches.empty?

    base_today = Time.zone.now.change(hour: 10, min: 0, sec: 0)
    base_today = Time.current if base_today.future?

    STREAK_DAYS.times do |i|
      stretch = stretches[i % stretches.size]
      user.stretch_logs.create!(
        stretch: stretch,
        performed_at: base_today - i.days
      )
    end
  end

  # モザイクデザインを取得する
  def find_design!(name)
    MosaicDesign.find_by!(name: name) # find_by! = 題材 YAML の seed より先に呼ぶと ActiveRecord::RecordNotFound になるから、 seeds.rb の最後で呼ぶ。
  end
end
