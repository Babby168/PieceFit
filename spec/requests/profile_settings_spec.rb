require "rails_helper"

RSpec.describe "ProfileSettings", type: :request do
  describe "GET /profile_settings" do
    let(:user) { create(:user) }

    context "未ログインの場合" do
      it "ログインページへリダイレクトされること" do
        get profile_settings_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返されること" do
        get profile_settings_path
        expect(response).to have_http_status(:success)
      end

      it "ページ見出しと説明文が表示されること" do
        get profile_settings_path
        expect(response.body).to include("プロフィール設定")
        expect(response.body).to include("アカウント情報の確認と変更ができます。")
      end

      it "各メニュー項目とサブタイトルが表示されること" do
        get profile_settings_path
        expect(response.body).to include("ニックネーム")
        expect(response.body).to include(user.nickname)
        expect(response.body).to include("メールアドレス")
        expect(response.body).to include(user.email)
        expect(response.body).to include("パスワードの変更")
        expect(response.body).to include("********")
        expect(response.body).to include("ログアウト")
        expect(response.body).to include("アカウントの削除")
        expect(response.body).to include("この操作は取り消せません。全てのデータが失われます。")
      end

      it "ログアウト確認モーダルが表示用に含まれること" do
        get profile_settings_path
        expect(response.body).to include("ログアウトしますか？")
        expect(response.body).to include('data-controller="confirm-dialog"')
        expect(response.body).to include(destroy_user_session_path)
      end
    end
  end
end
