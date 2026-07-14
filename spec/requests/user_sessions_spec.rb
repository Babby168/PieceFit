require "rails_helper"

RSpec.describe "UserSessions", type: :request do
  describe "GET /users/sign_in" do
    it "ログインページが表示されること" do
      get new_user_session_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("ログイン")
    end

    it "メールアドレスとパスワードの入力欄が表示されること" do
      get new_user_session_path

      expect(response.body).to include('type="email"')
      expect(response.body).to include('type="password"')
    end

    it "ログインを保持するチェックボックスが表示されること" do
      get new_user_session_path

      expect(response.body).to include("ログインを保持する")
      expect(response.body).to include('name="user[remember_me]"')
    end

    it "アカウント作成へのリンクが表示されること" do
      get new_user_session_path

      expect(response.body).to include("アカウント作成")
    end

    it "パスワードリセットへのリンクが表示されること" do
      get new_user_session_path

      expect(response.body).to include("お忘れですか？")
    end
  end

  describe "POST /users/sign_in" do
    let(:password) { "password123" }
    let(:user) { create(:user, password: password, password_confirmation: password) }

    context "有効な認証情報の場合" do
      it "ログインに成功し、トップページにリダイレクトされること" do
        post user_session_path, params: {
          user: { email: user.email, password: password }
        }

        expect(response).to redirect_to(root_path)
        expect(request.env["warden"].user(:user)).to eq(user)
      end
    end

    context "無効なパスワードの場合" do
      it "ログインに失敗し、エラーメッセージが表示されること" do
        post user_session_path, params: {
          user: { email: user.email, password: "wrongpassword" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("Eメールまたはパスワードが違います。")
        expect(request.env["warden"].user(:user)).to be_nil
      end
    end

    context "存在しないメールアドレスの場合" do
      it "ログインに失敗し、エラーメッセージが表示されること" do
        post user_session_path, params: {
          user: { email: "unknown@example.com", password: password }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to eq("Eメールまたはパスワードが違います。")
        expect(request.env["warden"].user(:user)).to be_nil
      end
    end
  end
end
