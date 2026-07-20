class StretchesController < ApplicationController
  def index
    if params[:body_part].present?
      @stretches = Stretch.where(body_part: params[:body_part])
      # ↑ ビュー実装は次の「ストレッチ選択」issueで対応
    end
  end
end
