module StretchesHelper
  BODY_PART_COLORS = {
    "neck" => "bg-emerald-200",
    "shoulder" => "bg-purple-200",
    "waist" => "bg-yellow-200"
  }.freeze


  def body_part_color(part)
    BODY_PART_COLORS.fetch(part.to_s, "bg-base-100")
  end

  # リマインドの選択肢（開発環境では動作確認用の短い選択肢を先頭に足す）
  def reminder_delay_options
    options = [
      { label: "30分後", seconds: 30.minutes.to_i },
      { label: "1時間後", seconds: 1.hour.to_i },
      { label: "2時間後", seconds: 2.hours.to_i }
    ]
    options.unshift({ label: "10秒後(確認用)", seconds: 10 }) if Rails.env.development?
    options
  end
end
