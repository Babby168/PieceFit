class MosaicImageCompositionJob < ApplicationJob
  queue_as :default

  # Cloudinaryへの一時的なアップロード失敗（ネットワークエラー等）に備えてリトライする
  # 3回リトライすることで、Cloudinaryへのアップロード失敗を防止する
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(mosaic_art_id)
    mosaic_art = MosaicArt.find_by(id: mosaic_art_id)
    return unless mosaic_art

    # ImageComposerを使用して、mosaic_artの画像を生成
    tmp_path = Mosaic::ImageComposer.new(mosaic_art).call

    # Cloudinaryにアップロード
    result = Cloudinary::Uploader.upload(
      tmp_path,
      folder: "mosaic_arts",
      public_id: "mosaic_art_#{mosaic_art.id}",
      overwrite: true,
    )

    # mosaic_artの画像を更新
    mosaic_art.update!(
      image_url: result["secure_url"],
      image_public_id: result["public_id"],
    )
  ensure # 例外が発生しても、一時ファイルを削除する
    File.delete(tmp_path) if tmp_path && File.exist?(tmp_path)
  end
end