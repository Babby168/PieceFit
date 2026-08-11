require "rails_helper"

RSpec.describe "EmailChanges", type: :request do
  let(:user) { create(:user) }

  describe "GET /email/change" do
    context "未ログインユーザーの場合" do
      it "ログインページにリダイレクトされること" do
        get edit_email_change_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返されること" do
        get edit_email_change_path
        expect(response).to have_http_status(:success)
      end

      it "タイトル・説明・戻るリンクが表示されること" do
        get edit_email_change_path
        expect(response.body).to include("メールアドレスの変更")
        expect(response.body).to include("新しいメールアドレスを入力してください。")
        expect(response.body).to include("← 戻る")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end

  describe "PATCH /email/change" do
    context "未ログインユーザーの場合" do
      it "ログインページにリダイレクトされること" do
        patch email_change_path, params: { unconfirmed_email: { email: "new@example.com" } }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "有効な新しいメールアドレスの場合" do
        it "email はまだ変更されないこと" do
          expect {
            patch email_change_path, params: { user: { unconfirmed_email: "new@example.com" } }
          }.not_to change { user.reload.email }
        end

        it "unconfirmed_email とトークンが保存されること" do
          patch email_change_path, params: { user: { unconfirmed_email: "new@example.com" } }
          user.reload
          expect(user.unconfirmed_email).to eq("new@example.com")
          expect(user.email_change_token).to be_present
        end

        it "確認メールが新しいメールアドレス宛に送信されること" do
          expect {
            patch email_change_path, params: { user: { unconfirmed_email: "new@example.com" } }
          }.to have_enqueued_mail(EmailChangeMailer, :confirmation_instructions)
        end

        it "完了ページへリダイレクトされること" do
          patch email_change_path, params: { user: { unconfirmed_email: "new@example.com" } }
          expect(response).to redirect_to email_change_complete_path
        end
      end

      context "空文字の場合" do
        it "422ステータスが返されること" do
          patch email_change_path, params: { user: { unconfirmed_email: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "エラーメッセージ欄が表示されること" do
          patch email_change_path, params: { user: { unconfirmed_email: "" } }
          expect(response.body).to include("alert-error")
        end
      end

      context "形式が不正な場合" do
        it "422ステータスが返されること" do
          patch email_change_path, params: { user: { unconfirmed_email: "invalid_email" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "既に使用されているメールアドレスの場合" do
        before { create(:user, email: "duplicate@example.com") }

        it "422ステータスが返されること" do
          patch email_change_path, params: { user: { unconfirmed_email: "duplicate@example.com" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "確認メールが送信されないこと" do
          expect {
            patch email_change_path, params: { user: { unconfirmed_email: "duplicate@example.com" } }
          }.not_to have_enqueued_mail(EmailChangeMailer, :confirmation_instructions)
        end
      end

      context "現在のメールアドレスと同じ場合" do
        it "422ステータスが返されること" do
          patch email_change_path, params: { user: { unconfirmed_email: user.email } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "GET /email/change/complete" do
    context "未ログインユーザーの場合" do
      it "ログインページにリダイレクトされること" do
        get email_change_complete_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返されること" do
        get email_change_complete_path
        expect(response).to have_http_status(:success)
      end

      it "「プロフィール設定へ」ボタンが表示されること" do
        get email_change_complete_path
        expect(response.body).to include("プロフィール設定へ")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end

  describe "GET /email/change/confirm/:token" do
    context "有効なトークンの場合" do
      before do
        user.update!(unconfirmed_email: "new@example.com",
                     email_change_token: "valid_token",
                     email_change_token_sent_at: Time.current)
      end

      it "ログインしていなくてもemailが更新されること" do
        expect { get email_change_confirm_path(token: "valid_token") }
          .to change { user.reload.email }.to("new@example.com")
      end

      it "unconfirmed_email と トークンがクリアされること" do
        get email_change_confirm_path(token: "valid_token")
        user.reload
        expect(user.unconfirmed_email).to be_nil
        expect(user.email_change_token).to be_nil
      end

      it "完了ページへリダイレクトされること" do
        get email_change_confirm_path(token: "valid_token")
        expect(response).to redirect_to email_change_confirmed_path
      end
    end

    context "無効なトークンの場合" do
      it "編集ページへリダイレクトされること" do
        get email_change_confirm_path(token: "invalid_token")
        expect(response).to redirect_to edit_email_change_path
      end
    end

    context "期限切れのトークンの場合" do
      before do
        user.update!(unconfirmed_email: "new@example.com",
                     email_change_token: "expired_token",
                     email_change_token_sent_at: 25.hours.ago)
      end

      it "email が更新されずに編集ページへリダイレクトされること" do
        expect { get email_change_confirm_path(token: "expired_token") }
          .not_to change { user.reload.email }
        expect(response).to redirect_to edit_email_change_path
      end
    end
  end

  describe "GET /email/change/confirmed" do
    context "未ログインユーザーの場合" do
      it "ログインページにリダイレクトされること" do
        get email_change_confirmed_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返されること" do
        get email_change_confirmed_path
        expect(response).to have_http_status(:success)
      end

      it "完了メッセージと「プロフィール設定へ戻る →」ボタンが表示されること" do
        get email_change_confirmed_path
        expect(response.body).to include("メールアドレスの変更が完了しました！")
        expect(response.body).to include("プロフィール設定へ戻る →")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end
end
