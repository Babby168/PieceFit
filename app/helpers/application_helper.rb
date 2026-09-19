module ApplicationHelper
  def google_analytics_measurement_id
    return unless Rails.env.production?
    
    ENV["GA_MEASUREMENT_ID"].presence
  end
end
