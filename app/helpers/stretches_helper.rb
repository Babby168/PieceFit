module StretchesHelper
  BODY_PART_COLORS = {
    "neck" => "bg-emerald-200",
    "shoulder" => "bg-purple-200",
    "waist" => "bg-yellow-200"
  }.freeze


  def body_part_color(part)
    BODY_PART_COLORS.fetch(part.to_s, "bg-base-100")
  end
end
