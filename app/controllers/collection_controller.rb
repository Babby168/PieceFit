class CollectionController < ApplicationController
  before_action :authenticate_user!

  def index
    completed_by_design_id = latest_completed_arts_by_design_id

    # シリーズごとにコレクション枠を並べる
    @shelves = MosaicSeries.order(:position).includes(:mosaic_designs).map do |series|
      slots = series.mosaic_designs.sort_by(&:collection_position).map do |design|
        { design: design, mosaic_art: completed_by_design_id[design.id] }
      end

      { series_name: series.name, slots: slots }
    end

    @has_completed_art = completed_by_design_id.any?
  end

  private

  # 同じ題材を何度完成しても、枠に入るのは最新の1件だけ
  def latest_completed_arts_by_design_id
    # ログインユーザーのモザイクアートテーブルを取得
    current_user.mosaic_arts
                # 完成したモザイクアートを取得
                .completed
                # モザイクデザインとデザインピースを取得
                .includes(mosaic_design: :design_pieces)
                # 完成日時で降順、IDで降順で並べ替え
                .order(completed_at: :desc, id: :desc)
                # モザイクデザインIDごとに最新のモザイクアートを取得
                .each_with_object({}) do |art, by_design_id|
      by_design_id[art.mosaic_design_id] ||= art
    end
  end
end
