require "rails_helper"

RSpec.describe "Mypage", type: :request do
  describe "GET /mypage" do
    let(:user) { create(:user) }
    let!(:mosaic_design) { create(:mosaic_design, area_size_x: 2, area_size_y: 1) }

    context "未ログインの場合" do
      it "ログイン画面へリダイレクトすること" do
        get mypage_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

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

      context "連続達成ボーナスの flash がある場合" do
        let!(:stretch) { create(:stretch) }

        before do
          create(:design_piece, mosaic_design: mosaic_design, position: 0, color: [ "#111111", "#222222", "#333333", "#444444" ])
          create(:design_piece, mosaic_design: mosaic_design, position: 1)
          create(:mosaic_art, user: user, mosaic_design: mosaic_design).tap do |art|
            create(:piece, mosaic_art: art, position: 0, acquired_at: nil)
            create(:piece, mosaic_art: art, position: 1, acquired_at: nil)
            create(:piece, mosaic_art: art, position: 2, acquired_at: nil)
          end

          create(:stretch_log, user: user, stretch: stretch, performed_at: 2.days.ago)
          create(:stretch_log, user: user, stretch: stretch, performed_at: 1.day.ago)
          post stretch_logs_path, params: { stretch_id: stretch.id }
        end

        it "マイページにボーナスモーダルの文言が表示されること" do
          get mypage_path

          expect(response.body).to include("ボーナスピース獲得")
          expect(response.body).to include("data-controller=\"auto-open-dialog\"")
          expect(response.body).to include("3日間連続")
        end
      end

      context "モザイクアートが完成した場合" do
        let!(:stretch) { create(:stretch) }

        before do
          create(:design_piece, mosaic_design: mosaic_design, position: 0, color: [ "#111111", "#222222", "#333333", "#444444" ])
          create(:design_piece, mosaic_design: mosaic_design, position: 1)
          create(:mosaic_art, user: user, mosaic_design: mosaic_design).tap do |art|
            create(:piece, mosaic_art: art, position: 0, acquired_at: 1.day.ago)
            create(:piece, mosaic_art: art, position: 1, acquired_at: nil)
          end

          post stretch_logs_path, params: { stretch_id: stretch.id }
        end

        it "マイページに完成モーダルの文言が表示されること" do
          get mypage_path
          expect(response.body).to include("モザイクアート完成")
          expect(response.body).to include("data-controller=\"auto-open-dialog\"")
        end
      end

      it "通常のマイページアクセスでは完成モーダルが出ないこと" do
        get mypage_path
        expect(response.body).not_to include("モザイクアート完成")
      end

      it "通常のマイページアクセスではボーナスモーダルが出ないこと" do
        get mypage_path
        expect(response.body).not_to include("ボーナスピース獲得")
      end
      it "ニックネームが表示されること" do
        get mypage_path
        expect(response.body).to include(user.nickname)
      end

      it "実施履歴が表示されること" do
        stretch = create(:stretch, name: "肩まわし")
        create(:stretch_log, user: user, stretch: stretch, performed_at: Time.current)
        get mypage_path
        expect(response.body).to include("肩まわし")
        expect(response.body).to include("実施履歴")
      end

      it "継続記録が表示されること" do
        stretch = create(:stretch)
        create(:stretch_log, user: user, stretch: stretch, performed_at: Time.current)
        get mypage_path
        expect(response.body).to include("継続記録")
        expect(response.body).to include("1")
      end
    end
  end
end
