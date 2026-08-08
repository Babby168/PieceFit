class MypageController < ApplicationController
  include MosaicGridAssignable

  # ログインしていない場合はログインページにリダイレクト（Deviseのメソッド）
  before_action :authenticate_user!

  def index
    # マイページにアクセスしたユーザーのグリッドを割り当て
    assign_mosaic_grid!(current_user)
    # マイページにアクセスしたユーザーのストレッチログを取得
    @stretch_logs = current_user.stretch_logs
                                .includes(:stretch)
                                 # ストレッチログを作成日時で降順に並べ替え
                                 .order(performed_at: :desc)
                                 # 最新の5件を取得
                                 .limit(5)
    # マイページにアクセスしたユーザーのストレッチ連続日数を取得
    @streak_days = current_user.current_streak_days
  end
end
