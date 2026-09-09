class PieceAcquisitionService
  # 1日に獲得できるピースの上限
  DAILY_LIMIT = 3
  # ピース獲得ロジックの結果を表す構造体
  Result = Struct.new(:status, :piece, :art_completed, keyword_init: true)

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
    result = mosaic_art.with_lock do
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
      art_completed = mosaic_art.pieces.unacquired.none?
      mosaic_art.update!(completed_at: Time.current) if art_completed

      # ピース獲得ロジックの結果を返す
      Result.new(status: :acquired, piece: piece, art_completed: art_completed)
    end

    # モザイクアートの画像を合成する
    MosaicImageCompositionJob.perform_later(mosaic_art.id) if result.art_completed
    result
  end


  # 現在のモザイクアートを取得
  def ensure_current_mosaic_art!
    # 指定ユーザーの進行中のモザイクアートを取得
    art = @user.mosaic_arts.in_progress.order(:created_at).last
    # 進行中のモザイクアートが存在する場合はそれを返す
    return art if art

    # モザイクデザインテーブルの件数を取得
    total = MosaicDesign.count
    # モザイクデザインテーブルの件数が0の場合はnilを返す
    return nil if total.zero?

    # ユーザーのこれまでの完成数を題材数で割った余りを取得（今周で何件使ったか）
    used_in_round = @user.mosaic_arts.completed.count % total
    # ユーザーが完成させたモザイクアートが０件の場合は、空配列を返す
    used_ids = if used_in_round.zero?
      [] # 0件完成、または１周ちょうど終わった直後
    else
      # そうでない場合は、題材の完成させた日時とその題材IDでソートして、最後のused_in_round件の題材IDを配列で取得
      @user.mosaic_arts.completed.order(:completed_at, :id).last(used_in_round).pluck(:mosaic_design_id)
    end

    # モザイクデザインテーブルから、ユーザーが今周で使った題材IDを除いたものをランダムに取得
    random_design = MosaicDesign.where.not(id: used_ids).order(Arel.sql("RANDOM()")).first

    # モザイクアートを作成して、デザインのピースを作成
    @user.mosaic_arts.create!(mosaic_design: random_design).tap do |mosaic_art|
      # デザインのピースを作成
      random_design.design_pieces.find_each do |dp|
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
