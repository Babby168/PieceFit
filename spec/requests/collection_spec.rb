require "rails_helper"

RSpec.describe "Collection", type: :request do
  describe "GET /collection" do
    let(:user) { create(:user) }
    let(:mosaic_design) { create(:mosaic_design, name: "ドクター") }

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトする" do
        get collection_path
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログインしている場合" do
      before { sign_in user }

      it "200が返ること" do
        get collection_path
        expect(response).to have_http_status(:success)
      end

      it "完成アートが0件なら空状態を出すこと" do
        get collection_path
        expect(response.body).to include("まだ完成した作品はありません")
        expect(response.body).to include(stretches_path)
      end

      context "完成済みと進行中がある場合" do
        let!(:completed_art) do
          create(:mosaic_art, user: user, mosaic_design: mosaic_design, completed_at: 1.day.ago, image_url: "https://res.cloudinary.com/demo/mosaic.png")
        end
        let!(:in_progress_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

        it "完成済みのタイトルと画像だけ出すこと" do
          get collection_path
          expect(response.body).to include("ドクター")
          expect(response.body).to include("https://res.cloudinary.com/demo/mosaic.png")
        end

        it "進行中のアートを出さないこと" do
          get collection_path
          expect(response.body).not_to include("まだ完成した作品はありません")
          expect(user.mosaic_arts.in_progress).to include(in_progress_art)
        end
      end

      it "他人の完成アートを出さないこと" do
        other_user = create(:user)
        create(:mosaic_art, user: other_user, mosaic_design: mosaic_design, completed_at: Time.current, image_url: "https://res.cloudinary.com/demo/other.png")

        get collection_path
        expect(response.body).not_to include("https://res.cloudinary.com/demo/other.png")
        expect(response.body).to include("まだ完成した作品はありません")
      end
    end
  end
end
