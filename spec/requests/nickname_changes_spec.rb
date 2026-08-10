require "rails_helper"

RSpec.describe "NicknameChanges", type: :request do
  let(:user) { create(:user) }

  describe "GET /nickname/change" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get nickname_change_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get nickname_change_path
        expect(response).to have_http_status(:success)
      end

      it "タイトル・サブタイトル・戻るリンクが表示されること" do
        get nickname_change_path
        expect(response.body).to include("ニックネームの変更")
        expect(response.body).to include("新しいニックネームを入力してください。")
        expect(response.body).to include("← 戻る")
        expect(response.body).to include(profile_settings_path)
      end

      it "入力欄のプレースホルダーが表示されること" do
        get nickname_change_path
        expect(response.body).to include("新しいニックネームを入力")
      end
    end
  end

  describe "PATCH /nickname/change" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        patch nickname_change_path, params: { user: { nickname: "新しい名前" } }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      context "有効なニックネームの場合" do
        it "ニックネームが更新されること" do
          patch nickname_change_path, params: { user: { nickname: "新しい名前" } }
          expect(user.reload.nickname).to eq("新しい名前")
        end

        it "完了ページへリダイレクトされること" do
          patch nickname_change_path, params: { user: { nickname: "新しい名前" } }
          expect(response).to redirect_to nickname_change_complete_path
        end
      end

      context "空文字の場合" do
        it "422ステータスが返されること" do
          patch nickname_change_path, params: { user: { nickname: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "ニックネームが変更されないこと" do
          expect {
            patch nickname_change_path, params: { user: { nickname: "" } }
          }.not_to change { user.reload.nickname }
        end

        it "エラーメッセージ欄が表示されること" do
          patch nickname_change_path, params: { user: { nickname: "" } }
          expect(response.body).to include("alert-error")
        end
      end

      context "既に使用されているニックネームの場合" do
        before { create(:user, nickname: "既存の名前") }

        it "ニックネームが変更されないこと" do
          patch nickname_change_path, params: { user: { nickname: "既存の名前" } }
          expect(user.reload.nickname).not_to eq("既存の名前")
        end

        it "エラーメッセージ欄が表示されること" do
          patch nickname_change_path, params: { user: { nickname: "既存の名前" } }
          expect(response.body).to include("alert-error")
        end
      end
    end
  end

  describe "GET /nickname/change/complete" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get nickname_change_complete_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get nickname_change_complete_path
        expect(response).to have_http_status(:success)
      end

      it "完了メッセージとボタンが表示されること" do
        get nickname_change_complete_path
        expect(response.body).to include("変更が完了しました！")
        expect(response.body).to include("ニックネームの変更が正常に完了しました。")
        expect(response.body).to include("新しい名前でPieceFitをお楽しみください。")
        expect(response.body).to include("プロフィール設定へ戻る →")
        expect(response.body).to include(profile_settings_path)
      end
    end
  end
end
