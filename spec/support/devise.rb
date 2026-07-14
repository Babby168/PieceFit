RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers, type: :request

  config.before(type: :request) { Warden.test_mode! }
  config.after(type: :request) { Warden.test_reset! }
end
