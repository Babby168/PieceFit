class ReminderMessageBuilder
  # 残りのピースがこの数以下なら「完成間近」とみなす
  NEARLY_DONE_THRESHOLD = 10

  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  # 優先順位は 完成間近 > ボーナス予告 > 今日の残りピース
  def call
    # 今日の上限3ピースを獲得済みの日は、どの文面も成り立たないので通知しない
    return nil if remaining_today <= 0

    nearly_done_message || streak_message || daily_piece_message
  end

  private

  # 今日あと何ピース獲得できるか（ボーナスピースは上限に数えない）
  def remaining_today
    @remaining_today ||= PieceAcquisitionService::DAILY_LIMIT - acquired_today_count
  end

  # 今日すでに獲得したピース数
  def acquired_today_count
    Piece.joins(:mosaic_art)
         .where(mosaic_arts: { user_id: @user.id }, is_bonus: false)
         .acquired_on(Time.zone.today)
         .count
  end

  # 進行中のモザイクアート（進行中のものがなければ nil）
  def current_mosaic_art
    return @current_mosaic_art if defined?(@current_mosaic_art)

    @current_mosaic_art = @user.mosaic_arts.in_progress.order(:created_at).last
  end

  # 完成まで残り何ピースか（進行中のアートがなければ nil）
  def remaining_pieces
    return nil unless current_mosaic_art

    @remaining_pieces ||= current_mosaic_art.pieces.unacquired.count
  end

  # 連続日数（今日ストレッチ済みなら1以上）
  def streak_days
    @streak_days ||= @user.current_streak_days
  end

  # ボーナスまであと何日か
  def days_to_bonus
    threshold = StreakBonusService::STREAK_THRESHOLD
    threshold - (streak_days % threshold)
  end

  # 完成間近
  def nearly_done_message
    return nil if remaining_pieces.nil? || remaining_pieces.zero?
    return nil if remaining_pieces > NEARLY_DONE_THRESHOLD

    {
      title: "完成まであと#{remaining_pieces}ピース",
      body: "もう1回ストレッチして、アートを完成に近づけませんか？"
    }
  end

  # ボーナス予告（次の1日でボーナスに届くときだけ出す）
  def streak_message
    return nil unless days_to_bonus == 1

    {
      title: "連続#{streak_days}日目！あと1日でボーナスピース",
      body: "今日のピースをもう1つ埋めておきましょう。"
    }
  end

  # 今日の残りピース（上の2つに当てはまらないときの標準文面）
  def daily_piece_message
    {
      title: "今日のピース、あと#{remaining_today}つ獲得できます",
      body: "1分ストレッチでピースを埋めませんか？"
    }
  end
end
