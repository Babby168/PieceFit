require "rails_helper"

RSpec.describe "Reminders", type: :request do
  describe "GET /reminders/message" do
    let(:user) { create(:user) }

    context "未ログインの場合" do
      it "204 を返すこと" do
        get reminder_message_path
        expect(response).to have_http_status(:no_content)
      end
    end

    context "ログインしている場合" do
      let!(:mosaic_design) { create(:mosaic_design, area_size_x: 4, area_size_y: 5) }
      let!(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

      before { sign_in user }

      context "送る文面がある場合" do
        before { create_pieces(acquired: 0) }

        it "title と body を含む JSON を返すこと" do
          get reminder_message_path

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body["title"]).to be_present
          expect(response.parsed_body["body"]).to be_present
        end
      end

      context "今日すでに3ピース獲得している場合" do
        before { create_pieces(acquired: 3) }

        it "204 を返すこと" do
          get reminder_message_path
          expect(response).to have_http_status(:no_content)
        end
      end

      def create_pieces(acquired:)
        20.times do |position|
          create(:piece,
                 mosaic_art: mosaic_art,
                 position: position,
                 acquired_at: position < acquired ? Time.current : nil)
        end
      end
    end
  end
end
