require "rails_helper"

RSpec.describe MosaicImageCompositionJob, type: :job do
  let(:user) { create(:user) }
  let(:mosaic_design) { create(:mosaic_design, area_size_x: 1, area_size_y: 1) }
  let(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

  describe "#perform" do
    it "合成画像をCLoudinaryへ上げ、URLとpublic_idを保存して一時ファイルを消すこと" do
      tmp_path = Rails.root.join("tmp/mosaic_job_spec.png").to_s
      FileUtils.mkdir_p(File.dirname(tmp_path))
      File.write(tmp_path, "png")

      composer = instance_double(Mosaic::ImageComposer, call: tmp_path)
      allow(Mosaic::ImageComposer).to receive(:new).with(mosaic_art).and_return(composer)

      allow(Cloudinary::Uploader).to receive(:upload)
                                 .with(tmp_path,
                                       hash_including(folder: "mosaic_arts", public_id: "mosaic_art_#{mosaic_art.id}", overwrite: true)
                                     )
                                 .and_return(
                                  "secure_url" => "https://res.cloudinary.com/demo/mosaic.png",
                                  "public_id" => "mosaic_arts/mosaic_art_#{mosaic_art.id}"
                                 )

      described_class.perform_now(mosaic_art.id)

      mosaic_art.reload
      expect(mosaic_art.image_url).to eq("https://res.cloudinary.com/demo/mosaic.png")
      expect(mosaic_art.image_public_id).to eq("mosaic_arts/mosaic_art_#{mosaic_art.id}")
      expect(File.exist?(tmp_path)).to be false
    end

    it "対象の MosaicArt が無い場合は何もしないこと" do
      expect(Mosaic::ImageComposer).not_to receive(:new)
      expect(Cloudinary::Uploader).not_to receive(:upload)

      described_class.perform_now(-1)
    end
  end
end
