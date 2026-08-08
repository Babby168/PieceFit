class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # モダンブラウザでのみ動作する
  allow_browser versions: :modern
  # Deviseのコントローラーでのみ、 configure_permitted_parametersを実行
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(_resource)
    mypage_path
  end

  protected
  # パラメータの許可
  # ユーザー登録時に、nicknameを許可する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname ])
  end
end
