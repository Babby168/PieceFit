module MypageHelper
  # 体部位ごとのストレッチ回数からバーの幅を計算
  def body_part_bar_width_percent(count, max_count)
    # 最大回数が0の場合は0を返す
    return 0 if max_count.zero?
    # 回数を最大回数で割って100倍し、小数点以下を切り捨ててパーセントに変換
    # 1回以上なら最低 8%、0回なら 0%
    [ (count.to_f / max_count * 100).round, count.positive? ? 8 : 0 ].max
  end

  # いちばん少ない部位の文言を表示
  def least_active_body_part_message(body_part_counts)
    # すべての部位の回数が0の場合は空文字を返す
    return if body_part_counts.values.all?(&:zero?)

    # いちばん少ない部位の回数を取得
    min_count = body_part_counts.values.min
    # いちばん少ない部位の部位名を取得
    least_parts = body_part_counts.select { |_, count| count == min_count }.keys

    # いちばん少ない部位が複数ある場合は複数の部位が同じ回数ですと表示
    if least_parts.size > 1
      "複数の部位が同じ回数です"
    else
      # いちばん少ない部位の部位名と回数を表示
      part_name = t("stretches.body_parts.#{least_parts.first}")
      "いちばん少ない部位は#{part_name}です (#{min_count}回)"
    end
  end
end
