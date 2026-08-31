Rails.application.routes.draw do
  # 開発中はメールを確認するためのルートを追加
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # トップページ
  root "top#index"
  # ユーザー登録
  devise_for :users, controllers: { registrations: "users/registrations" }, skip: [ :passwords ]
  # 新規登録完了画面
  get "registration/complete", to: "registration_complete#show", as: :registration_complete

  # 部位/ストレッチ選択
  get "stretches(/:body_part)", to: "stretches#index", as: :stretches,
      constraints: { body_part: /neck|shoulder|waist/ }
  # ストレッチ実施ページ
  get "stretches/:id", to: "stretches#show", as: :stretch,
      constraints: { id: /\d+/ }

  # ストレッチ実施記録
  resources :stretch_logs, only: %i[create]

  # マイページ
  get "mypage", to: "mypage#index", as: :mypage

  # プライバシーポリシー/利用規約
  get "legal", to: "legal#index", as: :legal

  # プロフィール設定
  get "profile/settings", to: "profile_settings#show", as: :profile_settings

  # ニックネーム変更
  get "nickname/change", to: "nickname_changes#edit", as: :edit_nickname_change
  patch "nickname/change", to: "nickname_changes#update", as: :nickname_change
  get "nickname/change/complete", to: "nickname_changes#complete", as: :nickname_change_complete

  # メールアドレス変更
  get "email/change", to: "email_changes#edit", as: :edit_email_change
  patch "email/change", to: "email_changes#update", as: :email_change
  get "email/change/complete", to: "email_changes#complete", as: :email_change_complete
  get "email/change/confirm/:token", to: "email_changes#confirm", as: :email_change_confirm
  get "email/change/confirmed", to: "email_changes#confirmed", as: :email_change_confirmed

  # パスワード変更
  get "password/change", to: "password_changes#edit", as: :edit_password_change
  patch "password/change", to: "password_changes#update", as: :password_change
  get "password/change/complete", to: "password_changes#complete", as: :password_change_complete

  # アカウント削除
  get "account/delete", to: "account_deletes#show", as: :account_delete
  delete "account/delete", to: "account_deletes#destroy"
  get "account/delete/complete", to: "account_deletes#complete", as: :account_delete_complete

  # パスワードリセット（ログアウト中）
  get "password/reset", to: "password_resets#edit", as: :edit_password_reset
  patch "password/reset", to: "password_resets#update", as: :password_reset
  get "password/reset/complete", to: "password_resets#complete", as: :password_reset_complete
  get "password/reset/confirm/:token", to: "password_resets#confirm", as: :password_reset_confirm
  patch "password/reset/confirm/:token", to: "password_resets#reset", as: :password_reset_update
  get "password/reset/confirmed", to: "password_resets#confirmed", as: :password_reset_confirmed

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
