class StretchesController < ApplicationController
  # ストレッチ選択ページ
  def index
    if params[:body_part].present?
      @stretches = Stretch.where(body_part: params[:body_part])
    end
  end

  # ストレッチ実施ページ
  def show
    @stretch = Stretch.includes(:stretch_steps).find(params[:id])
  end
end
