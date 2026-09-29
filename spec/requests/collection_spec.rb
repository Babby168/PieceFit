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
      let!(:uncle_series) { create(:mosaic_series, name: "おじさんシリーズ", position: 1) }
      let!(:robo_series) { create(:mosaic_series, name: "ロボらんてくん", position: 2) }
      let!(:astronaut) do
        create(:mosaic_design, mosaic_series: uncle_series, name: "アストロノート", collection_position: 1)
      end
      let!(:chef) do
        create(:mosaic_design, mosaic_series: uncle_series, name: "シェフ", collection_position: 2)
      end
      let!(:robo) do
        create(:mosaic_design, mosaic_series: robo_series, name: "ロボらんてくん（非公式）", collection_position: 1)
      end

      before { sign_in user }

      it "200が返ること" do
        get collection_path
        expect(response).to have_http_status(:success)
      end

      it "完成が0件でも全枠を「？」で出し、題材名は出さないこと" do
        get collection_path

        expect(response.body).to include("まだ完成した作品はありません")
        expect(response.body).to include(stretches_path)
        expect(response.body).to include("おじさんシリーズ")
        expect(response.body).to include("ロボらんてくん")
        expect(response.body).to include("未獲得")
        expect(response.body).not_to include("アストロノート")
        expect(response.body).not_to include("シェフ")
        expect(response.body).not_to include("ロボらんてくん（非公式）")
      end

      context "完成済みと進行中がある場合" do
        let!(:older_completed) do
          create(:mosaic_art, user: user, mosaic_design: chef, completed_at: 2.days.ago, image_url: "https://res.cloudinary.com/demo/chef.png")
        end
        let!(:newer_completed) do
          create(:mosaic_art, user: user, mosaic_design: astronaut, completed_at: 1.day.ago, image_url: "https://res.cloudinary.com/demo/astronaut.png")
        end

        let!(:in_progress_art) { create(:mosaic_art, user: user, mosaic_design: robo) }

        it "完成した題材だけ名前と画像を出し、並びは住所順であること" do
          get collection_path

          expect(response.body).to include("アストロノート")
          expect(response.body).to include("シェフ")
          expect(response.body).to include("https://res.cloudinary.com/demo/astronaut.png")
          expect(response.body).to include("https://res.cloudinary.com/demo/chef.png")
          expect(response.body.index("アストロノート")).to be < response.body.index("シェフ")
          expect(response.body).not_to include("まだ完成した作品はありません")
        end

        it "進行中の題材名は出さないこと" do
          get collection_path

          expect(response.body).not_to include("ロボらんてくん（非公式）")
          expect(user.mosaic_arts.in_progress).to include(in_progress_art)
        end

        it "同じ題材を複数完成していても、最新の画像だけ出すこと" do
          create(:mosaic_art, user: user, mosaic_design: chef, completed_at: Time.current, image_url: "https://res.cloudinary.com/demo/chef-new.png")
          get collection_path

          expect(response.body).to include("https://res.cloudinary.com/demo/chef-new.png")
          expect(response.body).not_to include("https://res.cloudinary.com/demo/chef.png")
        end
      end

      it "他人の完成アートを出さないこと" do
        other_user = create(:user)
        create(:mosaic_art, user: other_user, mosaic_design: astronaut, completed_at: Time.current, image_url: "https://res.cloudinary.com/demo/other.png")

        get collection_path

        expect(response.body).not_to include("https://res.cloudinary.com/demo/other.png")
        expect(response.body).not_to include("アストロノート")
        expect(response.body).to include("まだ完成した作品はありません")
      end
    end
  end
end
