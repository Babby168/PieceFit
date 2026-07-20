require "rails_helper"

RSpec.describe "Stretches", type: :request do
  describe "GET /stretches" do
    it "200が返ること" do
      get stretches_path

      expect(response).to have_http_status(:success)
    end

    it "ページタイトルが表示されること" do
      get stretches_path

      expect(response.body).to include("気になる部位を選んでください")
    end

    it "首・肩・腰の部位カードが表示されること" do
      get stretches_path

      expect(response.body).to include("首")
      expect(response.body).to include("肩")
      expect(response.body).to include("腰")
    end

    it "各部位へのリンクが表示されること" do
      get stretches_path

      expect(response.body).to include('href="/stretches/neck"')
      expect(response.body).to include('href="/stretches/shoulder"')
      expect(response.body).to include('href="/stretches/waist"')
    end

    it "各部位の画像が表示されること" do
      get stretches_path

      expect(response.body).to include("/assets/stretches/parts/neck")
      expect(response.body).to include("/assets/stretches/parts/shoulder")
      expect(response.body).to include("/assets/stretches/parts/waist")
    end

    it "各部位カードに背景色クラスが適用されていること" do
      get stretches_path

      expect(response.body).to include("bg-emerald-200")
      expect(response.body).to include("bg-purple-200")
      expect(response.body).to include("bg-yellow-200")
    end
  end

  describe "GET /stretches/:body_part" do
    it "部位を指定しても200が返ること" do
      get stretches_path(body_part: :neck)

      expect(response).to have_http_status(:success)
    end
  end
end
