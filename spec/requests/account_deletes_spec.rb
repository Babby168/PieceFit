require "rails_helper"

RSpec.describe "AccountDeletes", type: :request do
  let(:user) { create(:user) }

  describe "GET /account/delete" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        get account_delete_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get account_delete_path
        expect(response).to have_http_status(:success)
      end

      it "タイトル・注意文・戻るリンクが表示されること" do
        get account_delete_path
        expect(response.body).to include("アカウントを削除しますか？")
        expect(response.body).to include("完全に失われます。")
        expect(response.body).to include("削除前の注意事項")
        expect(response.body).to include("← 戻る")
        expect(response.body).to include(profile_settings_path)
      end

      it "キャンセルと削除ボタンが表示されること" do
        get account_delete_path
        expect(response.body).to include("キャンセル")
        expect(response.body).to include("削除する")
      end
    end
  end

  describe "DELETE /account/delete" do
    context "未ログインの場合" do
      it "ログインページにリダイレクトされること" do
        delete account_delete_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "ユーザーが削除されること" do
        delete account_delete_path
        expect(User.exists?(user.id)).to eq(false)
      end

      it "関連する stretch_logs・mosaic_arts・pieces も削除されること" do
        stretch_log = create(:stretch_log, user: user)
        mosaic_art = create(:mosaic_art, user: user)
        piece = create(:piece, mosaic_art: mosaic_art)

        delete account_delete_path

        expect(StretchLog.exists?(stretch_log.id)).to eq(false)
        expect(MosaicArt.exists?(mosaic_art.id)).to eq(false)
        expect(Piece.exists?(piece.id)).to eq(false)
      end


      it "完了ページにリダイレクトされること" do
        delete account_delete_path
        expect(response).to redirect_to account_delete_complete_path
      end

      it "ログアウト状態になること" do
        delete account_delete_path
        expect(request.env["warden"].user(:user)).to be_nil
      end
    end
  end

  describe "GET /account/delete/complete" do
    context "未ログインの場合" do
      it "200ステータスが返ってくること" do
        get account_delete_complete_path
        expect(response).to have_http_status(:success)
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200ステータスが返ってくること" do
        get account_delete_complete_path
        expect(response).to have_http_status(:success)
      end

      it "完了メッセージとトップへのリンクが表示されること" do
        get account_delete_complete_path
        expect(response.body).to include("アカウントを削除しました！")
        expect(response.body).to include("ご利用いただきありがとうございました。")
        expect(response.body).to include("トップへ戻る →")
        expect(response.body).to include(root_path)
      end
    end
  end
end
