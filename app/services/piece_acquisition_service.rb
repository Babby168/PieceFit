class PieceAcquisitionService
  # 1日に獲得できるピースの上限
  DAILY_LIMIT = 3
  # ピース獲得ロジックの結果を表す構造体
  Result = Struct.new(:status, :piece, keyword_init: true)

  # ピース獲得ロジックを呼び出す
  def self.call(user)
    new(user).call
  end

  # インスタンスを初期化
  def initialize(user)
    @user = user
  end

  # ピース獲得ロジックを実行
  def call
    # 現在のモザイクアートを取得
    mosaic_art = ensure_current_mosaic_art!

    # モザイクアートが存在しない場合はエラーを返す
    return Result.new(status: :no_design) unless mosaic_art

    # モザイクアートをロックして同時実行を防ぐ
    mosaic_art.with_lock do
      # 1日に獲得できるピースの上限を超えている場合はエラーを返す
      return Result.new(status: :daily_limit) if daily_acquired_count >= DAILY_LIMIT
      # モザイクアートが完成している場合はエラーを返す
      return Result.new(status: :already_completed) if mosaic_art.completed?

      # １番小さい位置の未獲得のピースを取得
      piece = mosaic_art.pieces.unacquired.order(:position).lock.first
      # 未獲得のピースが存在しない場合はエラーを返す
      return Result.new(status: :already_completed) unless piece

      # ピースを獲得した時刻を更新して、ピースを獲得したことを記録
      piece.update!(acquired_at: Time.current)

      # モザイクアートの未獲得ピースが存在しない場合は、現在時刻を設定して完成とする
      if mosaic_art.pieces.unacquired.none?
        mosaic_art.update!(completed_at: Time.current)
      end

      # ピース獲得ロジックの結果を返す
      Result.new(status: :acquired, piece: piece)
    end
  end


  # 現在のモザイクアートを取得
  def ensure_current_mosaic_art!
    # 指定ユーザーの進行中のモザイクアートを取得
    art = @user.mosaic_arts.in_progress.order(:created_at).last
    # 進行中のモザイクアートが存在する場合はそれを返す
    return art if art

    # モザイクデザインテーブルから最初のデザインを取得
    design = MosaicDesign.first
    # デザインが存在しない場合はnilを返す
    return nil unless design

    # モザイクアートを作成して、デザインのピースを作成
    @user.mosaic_arts.create!(mosaic_design: design).tap do |mosaic_art|
      # デザインのピースを作成
      design.design_pieces.find_each do |dp|
        mosaic_art.pieces.create!(position: dp.position)
      end
    end
  end

  private

  # 1日に獲得できるピースの上限を超えている場合はエラーを返す
  def daily_acquired_count
    Piece.joins(:mosaic_art)
         .where(mosaic_arts: { user_id: @user.id }, is_bonus: false)
         .acquired_on(Time.zone.today)
         .count
  end
end
