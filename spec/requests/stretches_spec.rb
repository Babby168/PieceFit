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
    describe "ストレッチ選択ページ" do
      let!(:neck_stretch) do
        create(
          :stretch,
          name: "首の横伸ばし",
          body_part: :neck,
          description: "首筋を優しく伸ばして、PC作業による首の疲れをリフレッシュします。",
          key_visual_path: "stretches/key_visual/neck_kv.png"
        )
      end
      let!(:shoulder_stretch) do
        create(:stretch, :shoulder, name: "ショルダーロール")
      end

      before { get stretches_path(body_part: :neck) }

      it "200が返ること" do
        expect(response).to have_http_status(:success)
      end

      it "ページタイトルが表示されること" do
        expect(response.body).to include("ストレッチを選んでください")
      end

      it "指定部位のストレッチ名が表示されること" do
        expect(response.body).to include(neck_stretch.name)
      end

      it "指定部位のストレッチ説明が表示されること" do
        expect(response.body).to include(neck_stretch.description)
      end

      it "他部位のストレッチは表示されないこと" do
        expect(response.body).not_to include(shoulder_stretch.name)
      end

      it "キービジュアル画像が表示されること" do
        expect(response.body).to include("/assets/stretches/key_visual/neck_kv")
      end

      it "部位選択に戻るリンクが表示されること" do
        expect(response.body).to include("← 部位選択に戻る")
        expect(response.body).to include('href="/stretches"')
      end

      it "パンくずリストが表示されること" do
        expect(response.body).to include("トップ")
        expect(response.body).to include("部位選択")
        expect(response.body).to include("ストレッチ選択")
      end

      it "近日追加予定のプレースホルダーが表示されること" do
        expect(response.body).to include("近日追加予定")
      end

      it "首のストレッチカードに背景色クラスが適用されていること" do
        expect(response.body).to include("bg-emerald-200")
      end

      it "ストレッチ実施ページへのリンクが表示されること" do
        expect(response.body).to include("href=\"#{stretch_path(neck_stretch)}\"")
      end
    end

    describe "肩のストレッチ選択ページ" do
      before do
        create(:stretch, :shoulder, name: "ショルダーロール")
        get stretches_path(body_part: :shoulder)
      end

      it "肩のストレッチカードに背景色クラスが適用されていること" do
        expect(response.body).to include("bg-purple-200")
      end
    end

    describe "腰のストレッチ選択ページ" do
      before do
        create(:stretch, :waist, name: "椅子の腰部ツイスト")
        get stretches_path(body_part: :waist)
      end

      it "腰のストレッチカードに背景色クラスが適用されていること" do
        expect(response.body).to include("bg-yellow-200")
      end
    end

    context "指定部位にストレッチが登録されていない場合" do
      it "部位選択ページが表示されること" do
        get stretches_path(body_part: :neck)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("気になる部位を選んでください")
        expect(response.body).not_to include("ストレッチを選んでください")
      end
    end
  end

  describe "GET /stretches/:id" do
    let!(:stretch) do
      create(
        :stretch,
        name: "首の横伸ばし",
        body_part: :neck,
        description: "首筋を優しく伸ばして、PC作業による首の疲れをリフレッシュします。",
        point: "肩の力を抜き、ゆっくりと伸ばしましょう。",
        key_visual_path: "stretches/key_visual/neck_kv.png"
      )
    end
    let!(:step1) do
      create(:stretch_step, stretch: stretch, step_number: 1, description: "背筋を伸ばして座ります。")
    end
    let!(:step2) do
      create(:stretch_step, stretch: stretch, step_number: 2, description: "頭をゆっくり横に倒します。")
    end

    describe "ストレッチ実施ページ" do
      before { get stretch_path(stretch) }

      it "200が返ること" do
        expect(response).to have_http_status(:success)
      end

      it "ストレッチ名が表示されること" do
        expect(response.body).to include(stretch.name)
      end

      it "ストレッチの手順が表示されること" do
        expect(response.body).to include("ストレッチの手順")
        expect(response.body).to include(step1.description)
        expect(response.body).to include(step2.description)
      end

      it "キービジュアル画像が表示されること" do
        expect(response.body).to include("/assets/stretches/key_visual/neck_kv")
      end

      it "意識するポイントが表示されること" do
        expect(response.body).to include("意識するポイント")
        expect(response.body).to include(stretch.point)
      end

      it "カウントダウンタイマーのUIが表示されること" do
        expect(response.body).to include("残り時間")
        expect(response.body).to include("01:00")
        expect(response.body).to include("スタート")
        expect(response.body).to include("リセット")
      end

      it "ストレッチ選択に戻るリンクが表示されること" do
        expect(response.body).to include("← ストレッチ選択に戻る")
        expect(response.body).to include('href="/stretches/neck"')
      end

      it "パンくずリストが表示されること" do
        expect(response.body).to include("トップ")
        expect(response.body).to include("部位選択")
        expect(response.body).to include("ストレッチ選択")
        expect(response.body).to include("ストレッチ実施")
      end
    end

    context "存在しないストレッチIDの場合" do
      it "404が返ること" do
        get stretch_path(id: 0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
