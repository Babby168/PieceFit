Rails.application.routes.draw do
  root "top#index"
  devise_for :users, controllers: { registrations: "users/registrations" }
  get "registration/complete", to: "registration_complete#show", as: :registration_complete

  get "stretches(/:body_part)", to: "stretches#index", as: :stretches,
      constraints: { body_part: /neck|shoulder|waist/ }
  get "stretches/:id", to: "stretches#show", as: :stretch,
      constraints: { id: /\d+/ }

  resources :stretch_logs, only: %i[create]

  get "mypage", to: "mypage#index", as: :mypage
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
