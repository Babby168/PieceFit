require "rails_helper"

RSpec.describe "StretchLogs", type: :request do
  describe "POST /stretch_logs" do
    let!(:stretch) { create(:stretch) }

    context "ログインしている場合" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "ストレッチ実施記録が作成されること" do
        expect {
          post stretch_logs_path, params: { stretch_id: stretch.id }
        }.to change(StretchLog, :count).by(1)

        expect(response).to redirect_to(mypage_path)

        stretch_log = StretchLog.last
        expect(stretch_log.user).to eq(user)
        expect(stretch_log.stretch).to eq(stretch)
        expect(stretch_log.performed_at).to be_present
      end

      it "存在しないstretch_idの場合は作成されず422が返ること" do
        expect {
          post stretch_logs_path, params: { stretch_id: 0 }
        }.not_to change(StretchLog, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      context "ピース獲得連携" do
        let!(:mosaic_design) { create(:mosaic_design, area_size_x: 2, area_size_y: 2) }
        let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

        before do
          4.times do |i|
            create(:design_piece, mosaic_design: mosaic_design, position: i)
            create(:piece, mosaic_art: mosaic_art, position: i)
          end
        end

        it "POST成功時に未獲得ピースが1つ獲得されること" do
          expect {
            post stretch_logs_path, params: { stretch_id: stretch.id }
          }.to change { mosaic_art.pieces.acquired.count }.by(1)

          expect(response).to redirect_to(mypage_path)
          expect(mosaic_art.pieces.order(:position).first.acquired_at).to be_present
        end

        it "1日3回を超えるPOSTではログは増えるがピースは増えないこと" do
          3.times { post stretch_logs_path, params: { stretch_id: stretch.id } }

          expect {
            post stretch_logs_path, params: { stretch_id: stretch.id }
          }.to change(StretchLog, :count).by(1)
           .and change { mosaic_art.pieces.acquired.count }.by(0)

          expect(response).to redirect_to(mypage_path)
          expect(mosaic_art.pieces.acquired.count).to eq(3)
        end

        it "MosaicArt未作成でもPOST成功時に作成されピースが獲得されること" do
          mosaic_art.destroy!

          expect {
            post stretch_logs_path, params: { stretch_id: stretch.id }
          }.to change(MosaicArt, :count).by(1)
           .and change(StretchLog, :count).by(1)

          expect(response).to redirect_to(mypage_path)
          expect(user.mosaic_arts.last.pieces.acquired.count).to eq(1)
        end

        context "Accept が Turbo Stream の場合" do
          it "モザイクグリッドを replace する turbo_stream が返されること" do
            post stretch_logs_path,
                 params: { stretch_id: stretch.id },
                 headers: { "Accept" => "text/vnd.turbo-stream.html" }

            expect(response).to have_http_status(:ok)
            expect(response.media_type).to eq Mime[:turbo_stream]
            expect(response.body).to include('action="replace"')
            expect(response.body).to include('target="mosaic-grid"')
          end
        end

        it "3日連続時は通常1 + ボーナス1でピースが2つ増えること" do
          create(:stretch_log, user: user, stretch: stretch, performed_at: 2.days.ago)
          create(:stretch_log, user: user, stretch: stretch, performed_at: 1.day.ago)

          expect {
            post stretch_logs_path, params: { stretch_id: stretch.id }
          }.to change { mosaic_art.pieces.acquired.count }.by(2)

          pieces = mosaic_art.pieces.acquired.order(:position)
          expect(pieces.first.is_bonus).to be false
          expect(pieces.last.is_bonus).to be true
        end

        it "3日連続でボーナス付与時は flash[:streak_bonus_days] がセットされること" do
          create(:stretch_log, user: user, stretch: stretch, performed_at: 2.days.ago)
          create(:stretch_log, user: user, stretch: stretch, performed_at: 1.day.ago)

          post stretch_logs_path, params: { stretch_id: stretch.id }

          expect(flash[:streak_bonus_days]).to eq(3)
        end

        it "連続不足のときは flash[:streak_bonus_days] がセットされないこと" do
          post stretch_logs_path, params: { stretch_id: stretch.id }

          expect(flash[:streak_bonus_days]).to be_nil
        end
      end

      it "POST成功時にマイページにリダイレクトされること" do
        post stretch_logs_path, params: { stretch_id: stretch.id }
        expect(response).to redirect_to(mypage_path)
      end
    end

    context "ログインしていない場合" do
      it "実施記録は作成されず204が返ること" do
        expect {
          post stretch_logs_path, params: { stretch_id: stretch.id }
        }.not_to change(StretchLog, :count)

        expect(response).to have_http_status(:no_content)
      end

      it "ピースも獲得されないこと" do
        expect {
          post stretch_logs_path, params: { stretch_id: stretch.id }
        }.not_to change(Piece.acquired, :count)
      end
    end
  end
end
