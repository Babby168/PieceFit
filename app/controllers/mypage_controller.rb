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
                                 # 最新の3件を取得
                                 .limit(3)

    # マイページにアクセスしたユーザーの体部位ごとのストレッチ回数を取得
    @body_part_counts = current_user.stretch_counts_by_body_part

    # マイページにアクセスしたユーザーのストレッチ連続日数を取得
    @streak_days = current_user.current_streak_days
  end
end
