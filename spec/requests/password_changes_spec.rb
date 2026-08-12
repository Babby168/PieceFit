require "rails_helper"

RSpec.describe "PasswordChanges", type: :request do
  let(:current_password) { "password123" }
  let(:user) { create(:user, password: current_password, password_confirmation: current_password) }

  describe "GET /password/change" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get edit_password_change_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get edit_password_change_path
        expect(response).to have_http_status(:success)
      end

      it "タイトル・サブタイトル・戻るリンクが表示されること" do
        get edit_password_change_path
        expect(response.body).to include("パスワードの変更")
        expect(response.body).to include("アカウントのセキュリティを保つため、定期的な変更をお勧めします。")
        expect(response.body).to include("← 戻る")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end

  describe "PATCH /password/change" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        patch password_change_path, params: { user: { current_password: "password", password: "newpassword123", password_confirmation: "newpassword123" } }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "現在のパスワードが正しく、新しいパスワードが有効な場合" do
        it "パスワードが更新されること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "newpassword123", password_confirmation: "newpassword123" } }
          expect(user.reload.valid_password?("newpassword123")).to eq(true)
        end

        it "完了ページにリダイレクトされること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "newpassword123", password_confirmation: "newpassword123" } }
          expect(response).to redirect_to password_change_complete_path
        end

        it "ログイン状態が維持されること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "newpassword123", password_confirmation: "newpassword123" } }
          follow_redirect!
          expect(response).to have_http_status(:success)
        end
      end

      context "現在のパスワードが間違っている場合" do
        it "422ステータスが返ってくること" do
          patch password_change_path, params: { user: { current_password: "wrong_password", password: "newpassword123", password_confirmation: "newpassword123" } }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "パスワードが変更されないこと" do
          patch password_change_path, params: { user: { current_password: "wrong_password", password: "newpassword123", password_confirmation: "newpassword123" } }
          expect(user.reload.valid_password?(current_password)).to eq(true)
        end

        it "エラーメッセージ欄が表示されること" do
          patch password_change_path, params: { user: { current_password: "wrong_password", password: "newpassword123", password_confirmation: "newpassword123" } }
          expect(response.body).to include("alert-error")
        end
      end

      context "新しいパスワードと確認用パスワードが一致しないこと" do
        it "422ステータスが返ってくること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "newpassword123", password_confirmation: "different123" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "新しいパスワードが短すぎる場合" do
        it "422ステータスが返ってくること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "abc", password_confirmation: "abc" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "新しいパスワードが現在のパスワードと同じ場合" do
        it "422ステータスが返ってくること" do
          patch password_change_path, params: { user: { current_password: current_password, password: current_password, password_confirmation: current_password } }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "エラーメッセージ欄が表示されること" do
          patch password_change_path, params: { user: { current_password: current_password, password: current_password, password_confirmation: current_password } }
          expect(response.body).to include("alert-error")
        end

        it "パスワードが変更されないこと" do
          patch password_change_path, params: { user: { current_password: current_password, password: current_password, password_confirmation: current_password } }
          expect(user.reload.valid_password?(current_password)).to eq(true)
        end
      end

      context "新しいパスワードに全角文字・絵文字などの使用できない文字が含まれている場合" do
        it "422ステータスが返ってくること" do
          patch password_change_path, params: { user: { current_password: current_password, password: "あいうえお", password_confirmation: "あいうえお" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /password/change/complete" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get password_change_complete_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get password_change_complete_path
        expect(response).to have_http_status(:success)
      end

      it "完了メッセージとボタンが表示されること" do
        get password_change_complete_path
        expect(response.body).to include("完了しました！")
        expect(response.body).to include("パスワードの変更が正常に完了しました。")
        expect(response.body).to include("プロフィール設定へ戻る →")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end
end
