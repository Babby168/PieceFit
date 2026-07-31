# frozen_string_literal: true

require "fileutils"

module Mosaic
  module SeedTasks
    module_function

    ORIGINALS_DIR = Rails.root.join("db/seed_data/mosaic_designs/originals")
    COLORS_DIR = Rails.root.join("db/seed_data/mosaic_designs/colors")

    def extract_and_write!(design_key, area_size_x: 10, area_size_y: 9, palette_size: 24)
      source_path = ORIGINALS_DIR.join("#{design_key}.png")
      abort "元画像が見つかりません: #{source_path}" unless File.exist?(source_path)

      FileUtils.mkdir_p(COLORS_DIR)

      puts "Extracting colors from #{source_path}..."

      colors_by_position = Mosaic::ColorExtractor.new(
        source_path: source_path,
        area_size_x: area_size_x,
        area_size_y: area_size_y,
        palette_size: palette_size
      ).call

      payload = {
        "name" => design_key,
        "area_size_x" => area_size_x,
        "area_size_y" => area_size_y,
        "pieces" => colors_by_position.sort.map do |position, color|
          {
            "position" => position,
            "color" => color
          }
        end
      }

      output_path = COLORS_DIR.join("#{design_key}.yml")
      File.write(output_path, payload.to_yaml)
      puts "Wrote #{output_path} (#{payload['pieces'].size} pieces)"
    end
  end
end

namespace :mosaic do
  desc "元イラストから色データを抽出し YAML に出力する（例: rails mosaic:extract_colors[hero_01]）"
  task :extract_colors, [ :design_key ] => :environment do |_t, args|
    design_key = args[:design_key]
    abort "design_key を指定してください。例: rails mosaic:extract_colors[hero_01]" if design_key.blank?

    Mosaic::SeedTasks.extract_and_write!(design_key)
  end

  namespace :extract_colors do
    desc "originals/ 配下の全PNGを一括で色抽出する"
    task all: :environment do
      paths = Dir.glob(Mosaic::SeedTasks::ORIGINALS_DIR.join("*.png")).sort
      abort "元画像がありません: #{Mosaic::SeedTasks::ORIGINALS_DIR}" if paths.empty?

      paths.each do |path|
        design_key = File.basename(path, ".png")
        Mosaic::SeedTasks.extract_and_write!(design_key)
      end
    end
  end
end
