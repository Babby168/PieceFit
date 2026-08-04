require "rails_helper"

RSpec.describe "Mypage", type: :request do
  describe "GET /mypage" do
    let(:user) { create(:user) }
    let!(:mosaic_design) { create(:mosaic_design, area_size_x: 2, area_size_y: 1) }

    context "ログインしている場合" do
      before { sign_in user }

      context "モザイクアートをまだ持っていない場合" do
        before do
          create(:design_piece, mosaic_design: mosaic_design, position: 0,
                                 color: [ "#111111", "#222222", "#333333", "#444444" ])
          create(:design_piece, mosaic_design: mosaic_design, position: 1,
                                 color: [ "#555555", "#666666", "#777777", "#888888" ])
        end

        it "200が返ること" do
          get mypage_path
          expect(response).to have_http_status(:success)
        end

        it "初回アクセスでMosaicArtとデザイン分のPieceが作られること" do
          expect { get mypage_path }.to change(MosaicArt, :count).by(1)

          expect(Piece.count).to eq(2)
          expect(user.mosaic_arts.last.pieces.pluck(:position)).to contain_exactly(0, 1)
        end

        it "未獲得のピースはグレー表示になること" do
          get mypage_path
          expect(response.body).to include("bg-base-300")
        end
      end

      context "獲得済みのピースがある場合" do
        let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

        before do
          create(:design_piece, mosaic_design: mosaic_design, position: 0,
                                 color: [ "#111111", "#222222", "#333333", "#444444" ])
          create(:design_piece, mosaic_design: mosaic_design, position: 1)
          create(:piece, mosaic_art: mosaic_art, position: 0, acquired_at: Time.current)
          create(:piece, mosaic_art: mosaic_art, position: 1, acquired_at: nil)
        end

        it "獲得済みのマスはデザインの色が表示されること" do
          get mypage_path
          expect(response.body).to include("#111111")
        end

        it "獲得数が進捗として表示されること" do
          get mypage_path
          expect(response.body).to include("1 / 2 ピース")
        end
      end
    end
  end
end
