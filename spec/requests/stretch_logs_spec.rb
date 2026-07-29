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

        expect(response).to have_http_status(:no_content)

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
    end

    context "ログインしていない場合" do
      it "実施記録は作成されず204が返ること" do
        expect {
          post stretch_logs_path, params: { stretch_id: stretch.id }
        }.not_to change(StretchLog, :count)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
