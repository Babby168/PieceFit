require "rails_helper"

RSpec.describe Mosaic::ImageComposer, type: :service do
  let(:user) { create(:user) }
  let(:mosaic_design) { create(:mosaic_design, area_size_x: 1, area_size_y: 1) }
  let(:mosaic_art) { create(:mosaic_art, user: user, mosaic_design: mosaic_design) }

  before do
    create(:design_piece,
           mosaic_design: mosaic_design,
           position: 0,
           color: [ "#FF0000", "#00FF00", "#0000FF", "#FFFFFF" ])
  end

  describe "#call" do
    it "既知色の2*2ブロックを nearest 拡大したPNGを返すこと" do
      skip "libvips が利用できない環境ではスキップ" unless vips_available?

      path = described_class.new(mosaic_art).call

      image = Vips::Image.new_from_file(path)
      expect(image.width).to eq(80)
      expect(image.height).to eq(80)

      expect(rgb_at(image, 0, 0)).to eq([ 255, 0, 0 ])
      expect(rgb_at(image, 40, 0)).to eq([ 0, 255, 0 ])
      expect(rgb_at(image, 0, 40)).to eq([ 0, 0, 255 ])
      expect(rgb_at(image, 40, 40)).to eq([ 255, 255, 255 ])
    ensure
      File.delete(path) if path && File.exist?(path)
    end
  end

  def rgb_at(image, x, y)
    image.getpoint(x, y).first(3).map(&:round)
  end

  def vips_available?
    require "vips"
    Vips::VERSION.present?
  end
end
