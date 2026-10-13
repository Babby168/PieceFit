# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger]
  config.dsn = ENV['SENTRY_DSN']
  # エラーは今まで通り送るが、パフォーマンスのためにトレースは送らない
  config.traces_sample_rate = 0.0
  # 開発とテストでは、DSNがあっても送らない（本番環境のみ）
  config.enabled_environments = %w[production]
  # ユーザーのメールアドレスやパスワードをSentryに送らない（デフォルトでも false だが明示的に設定）
  config.send_default_pii = false
end
