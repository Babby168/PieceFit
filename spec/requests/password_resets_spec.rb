require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let(:current_password) { "password123" }
  let(:user) { create(:user, password: current_password, password_confirmation: current_password) }

  describe "GET /password/reset" do
    it "200ステータスが返されること" do
      get edit_password_reset_path
      expect(response).to have_http_status(:success)
    end

    it "タイトル・説明・ログインへのリンクが表示されること" do
      get edit_password_reset_path
      expect(response.body).to include("パスワードを再設定")
      expect(response.body).to include("ご登録のメールアドレスを入力してください。")
      expect(response.body).to include(new_user_session_path)
    end
  end

  describe "PATCH /password/reset" do
    context "登録済みのメールアドレスの場合" do
      it "トークンと送信日時が保存されること" do
        patch password_reset_path, params: { user: { email: user.email } }
        user.reload
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
      end

      it "再設定メールが送信されること" do
        expect {
          patch password_reset_path, params: { user: { email: user.email } }
        }.to have_enqueued_mail(PasswordResetMailer, :reset_instructions)
      end

      it "完了ページへリダイレクトされること" do
        patch password_reset_path, params: { user: { email: user.email } }
        expect(response).to redirect_to(password_reset_complete_path)
      end
    end

    context "存在しないメールアドレスの場合" do
      it "完了ページにリダイレクトされること" do
        patch password_reset_path, params: { user: { email: "unknown@example.com" } }
        expect(response).to redirect_to password_reset_complete_path
      end

      it "再設定メールが送信されないこと" do
        expect {
          patch password_reset_path, params: { user: { email: "unknown@example.com" } }
        }.not_to have_enqueued_mail(PasswordResetMailer, :reset_instructions)
      end
    end

    context "空文字の場合" do
      it "422ステータスが返されること" do
        patch password_reset_path, params: { user: { email: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "エラーメッセージ欄が表示されること" do
        patch password_reset_path, params: { user: { email: "" } }
        expect(response.body).to include("alert-error")
      end

      it "再設定メールが送信されないこと" do
        expect {
          patch password_reset_path, params: { user: { email: "" } }
        }.not_to have_enqueued_mail(PasswordResetMailer, :reset_instructions)
      end
    end

    context "形式が不正な場合" do
      it "422ステータスが返されること" do
        patch password_reset_path, params: { user: { email: "invalid_email" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /password/reset/complete" do
    it "200ステータスが返されること" do
      get password_reset_complete_path
      expect(response).to have_http_status(:success)
    end

    it "送信完了メッセージとログインへのリンクが表示されること" do
      get password_reset_complete_path
      expect(response.body).to include("確認メールを送信しました！")
      expect(response.body).to include("ログインに戻る")
      expect(response.body).to include(new_user_session_path)
    end
  end

  describe "GET /password/reset/confirm/:token" do
    context "有効なトークンの場合" do
      let(:raw_token) { user.generate_reset_password_token! }

      it "200ステータスが返されること" do
        get password_reset_confirm_path(token: raw_token)
        expect(response).to have_http_status(:success)
      end

      it "再設定フォームが表示されること" do
        get password_reset_confirm_path(token: raw_token)
        expect(response.body).to include("パスワード再設定")
        expect(response.body).to include("新しいパスワード")
        expect(response.body).to include("パスワードを更新する")
      end

      it "この時点ではパスワードが変わらないこと" do
        expect {
          get password_reset_confirm_path(token: raw_token)
        }.not_to change { user.reload.encrypted_password }
      end
    end

    context "無効なトークンの場合" do
      it "申請ページへリダイレクトされること" do
        get password_reset_confirm_path(token: "invalid_token")
        expect(response).to redirect_to edit_password_reset_path
      end
    end

    context "期限切れのトークンの場合" do
      let(:raw_token) { user.generate_reset_password_token! }

      before do
        raw_token
        user.update_columns(reset_password_sent_at: 7.hours.ago)
      end

      it "申請ページへリダイレクトされること" do
        get password_reset_confirm_path(token: raw_token)
        expect(response).to redirect_to edit_password_reset_path
      end
    end
  end

  describe "PATCH /password/reset/confirm/:token" do
   let(:raw_token) { user.generate_reset_password_token! }
   let(:new_password) { "newpassword123" }

   context "有効なトークンで新しいパスワードが正しい場合" do
    it "パスワードが更新されること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: new_password, password_confirmation: new_password } }
      expect(user.reload.valid_password?(new_password)).to eq(true)
    end

    it "トークンがクリアされること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: new_password, password_confirmation: new_password } }
      user.reload
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_sent_at).to be_nil
    end

    it "完了ページへリダイレクトされること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: new_password, password_confirmation: new_password } }
      expect(response).to redirect_to password_reset_confirmed_path
    end

    it "ログイン状態にならないこと" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: new_password, password_confirmation: new_password } }
      expect(request.env["warden"].user(:user)).to be_nil
    end
   end

   context "現在のパスワードと同じ場合" do
    it "422ステータスが返されること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: current_password, password_confirmation: current_password } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "パスワードが変わらないこと" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: current_password, password_confirmation: current_password } }
      expect(user.reload.valid_password?(current_password)).to eq(true)
    end
   end

   context "確認用パスワードが一致しない場合" do
    it "422ステータスが返されること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: new_password, password_confirmation: "different123" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
   end

   context "新しいパスワードが短すぎる場合" do
    it "422ステータスが返されること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: "abc", password_confirmation: "abc" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
   end

   context "全角文字が含まれる場合" do
    it "422ステータスが返されること" do
      patch password_reset_update_path(token: raw_token),
            params: { user: { password: "あいうえお", password_confirmation: "あいうえお" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
   end

   context "無効なトークンの場合" do
    it "申請ページへリダイレクトされること" do
      patch password_reset_update_path(token: "invalid_token"),
            params: { user: { password: new_password, password_confirmation: new_password } }
      expect(response).to redirect_to edit_password_reset_path
    end
   end
  end

  describe "GET /password/reset/confirmed" do
    it "200ステータスが返されること" do
      get password_reset_confirmed_path
      expect(response).to have_http_status(:success)
    end

    it "完了メッセージとログインページへのリンクが表示されること" do
      get password_reset_confirmed_path
      expect(response.body).to include("パスワードの再設定が完了しました！")
      expect(response.body).to include("ログインページへ")
      expect(response.body).to include(new_user_session_path)
    end
  end
end
