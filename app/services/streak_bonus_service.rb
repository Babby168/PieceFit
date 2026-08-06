class StreakBonusService
  # 連続アクティビティの閾値
  STREAK_THRESHOLD = 3
  # 結果を格納する構造体
  Result = Struct.new(:status, :piece, :streak_days, keyword_init: true)

  # サービスを呼び出すクラスメソッド
  def self.call(user)
    new(user).call
  end

  # インスタンスを初期化
  def initialize(user)
    @user = user
  end

  # 連続アクティビティの日数を取得
  def call
    streak_days = consecutive_active_days
    # 連続アクティビティが0日の場合は対象外
    return Result.new(status: :not_eligible, streak_days: streak_days) if streak_days.zero?
    # 連続アクティビティが閾値の倍数でない場合は対象外
    return Result.new(status: :not_eligible, streak_days: streak_days) unless (streak_days % STREAK_THRESHOLD).zero?

    # 連続アクティビティが閾値の倍数の場合はボーナスを付与
    return Result.new(status: :already_awarded, streak_days: streak_days) if bonus_awarded_today?

    # ボーナスを付与
    grant_bonus_piece!(streak_days)
  end

  private

  # 今日を起点に、StretchLog がある日を1日ずつ遡って連続日数を数える
  def consecutive_active_days
    # StretchLog を取得
    dates = @user.stretch_logs
                 # 90日以内のログを取得
                 .where(performed_at: 90.days.ago.beginning_of_day..Time.current)
                 # 日付を取得
                 .pluck(:performed_at)
                 # 日付を配列に変換
                 .map { |t| t.in_time_zone.to_date }
                 # 重複を削除
                 .uniq
                 # ソート
                 .sort
                 # 逆順にソート
                 .reverse

    # 今日が最初の日付でない場合は対象外
    return 0 unless dates.first == Time.zone.today

    # 連続日数を数える
    count = 0
    # 今日を起点に遡る
    expected = Time.zone.today
    dates.each do |date|
      # 日付が一致しない場合は終了
      break unless date == expected
      # 連続日数を増やす
      count += 1
      # 前日を期待する
      expected -= 1.day
    end
    # 連続日数を返す
    count
  end

  # 今日はすでにボーナスが付与されているかどうかを返す
  def bonus_awarded_today?
    # モザイクアートのピースを取得
    Piece.joins(:mosaic_art)
         # 指定したユーザーのモザイクアートで、ボーナスが付与されているピースを取得
         .where(mosaic_arts: { user_id: @user.id }, is_bonus: true)
         # 今日に取得されたピースを取得
         .acquired_on(Time.zone.today)
         # 存在するかどうかを返す
         .exists?
  end

  # ボーナスを付与する
  def grant_bonus_piece!(streak_days)
    # モザイクアートを取得
    mosaic_art = PieceAcquisitionService.new(@user).ensure_current_mosaic_art!
    # モザイクアートが存在しない場合は対象外
    return Result.new(status: :no_design, streak_days: streak_days) unless mosaic_art

    # モザイクアートをロックしてボーナスを付与
    mosaic_art.with_lock do
      # モザイクアートがすでに完成している場合は対象外
      return Result.new(status: :already_completed, streak_days: streak_days) if mosaic_art.completed?

      piece = mosaic_art.pieces.unacquired.order(:position).lock.first
      # ピースが存在しない場合は対象外
      return Result.new(status: :already_completed, streak_days: streak_days) unless piece

      # ピースを取得
      piece.update!(acquired_at: Time.current, is_bonus: true)

      # モザイクアートがすでに完成している場合は更新
      if mosaic_art.pieces.unacquired.none?
        mosaic_art.update!(completed_at: Time.current)
      end

      # 結果を返す
      Result.new(status: :awarded, piece: piece, streak_days: streak_days)
    end
  end
end
