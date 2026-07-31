stretches_data = [
  {
    name: "首の横伸ばし",
    body_part: :neck,
    description: "首筋を優しく伸ばして、PC作業による首の疲れをリフレッシュします。",
    point: "無理に引っ張らず、頭の自重と手の重みだけで自然に伸ばしましょう。",
    key_visual_path: "stretches/key_visual/neck_kv.png",
    steps: [
      { step_number: 1, image_path: "stretches/neck/neck_1.png", description: "背筋を伸ばし、視線を前に向けます。" },
      { step_number: 2, image_path: "stretches/neck/neck_2.png", description: "右手で頭の左側を軽く押さえ、頭をゆっくり右へ傾けます。" },
      { step_number: 3, image_path: "stretches/neck/neck_3.png", description: "左肩が上がらないよう、意識して下げた状態を保ちます。" },
      { step_number: 4, image_path: "stretches/neck/neck_4.png", description: "深く深呼吸しながら、30秒キープ。左右を入れ替えて同様に行います。" }
    ]
  },
  {
    name: "ショルダーロール",
    body_part: :shoulder,
    description: "肩甲骨を大きく回して、肩周りの血流を改善し、コリをほぐします。",
    point: "首を長く保ち、余計な力を抜きましょう。肩甲骨の動きを感じて。",
    key_visual_path: "stretches/key_visual/shoulder_kv.png",
    steps: [
      { step_number: 1, image_path: "stretches/shoulder/shoulder_1.png", description: "背筋を伸ばし、リラックスした姿勢で座るか立ちます。" },
      { step_number: 2, image_path: "stretches/shoulder/shoulder_2.png", description: "両肩を耳の方へゆっくりと持ち上げます。" },
      { step_number: 3, image_path: "stretches/shoulder/shoulder_3.png", description: "肩甲骨を寄せるようにして、肩を大きく後ろに回します。" },
      { step_number: 4, image_path: "stretches/shoulder/shoulder_4.png", description: "ゆっくりと肩を下ろし、円を描くように繰り返します。" }
    ]
  },
  {
    name: "椅子の腰部ツイスト",
    body_part: :waist,
    description: "座ったまま身体をツイストし、腰回りの深層筋を穏やかに緩めます。",
    point: "腰からねじるのではなく、お腹、胸、肩、最後に首が回るように順にねじります。",
    key_visual_path: "stretches/key_visual/waist_kv.png",
    steps: [
      { step_number: 1, image_path: "stretches/waist/waist_1.png", description: "背筋をまっすぐに保ち、椅子にしっかりと座ります。" },
      { step_number: 2, image_path: "stretches/waist/waist_2.png", description: "右の膝を左手で押さえ、右手で椅子の背もたれか座面の後ろ部分を持ちます。" },
      { step_number: 3, image_path: "stretches/waist/waist_3.png", description: "息をツイストして、上体をゆっくり回します。" },
      { step_number: 4, image_path: "stretches/waist/waist_4.png", description: "同じ位置で3回深く深呼吸。ゆっくり正面に戻り、反対側も行います。" }
    ]
  }
]

stretches_data.each do |data|
  stretch = Stretch.find_or_create_by!(name: data[:name]) do |s|
    s.body_part = data[:body_part]
    s.description = data[:description]
    s.point = data[:point]
    s.key_visual_path = data[:key_visual_path]
  end

  data[:steps].each do |step_data|
    StretchStep.find_or_create_by(stretch: stretch, step_number: step_data[:step_number]) do |s|
      s.image_path = step_data[:image_path]
      s.description = step_data[:description]
    end
  end
end

mosaic_color_dir = Rails.root.join("db/seed_data/mosaic_designs/colors")
Dir.glob(mosaic_color_dir.join("*.yml")).sort.each do |yaml_path|
  data = YAML.safe_load_file(yaml_path, permitted_classes: [ Symbol ], aliases: true)
  next if data.blank?

  mosaic_design = MosaicDesign.find_or_initialize_by(name: data["name"])
  mosaic_design.area_size_x = data["area_size_x"]
  mosaic_design.area_size_y = data["area_size_y"]
  mosaic_design.save!

  Array(data["pieces"]).each do |piece_data|
    design_piece = DesignPiece.find_or_initialize_by(
      mosaic_design: mosaic_design,
      position: piece_data["position"]
    )
    design_piece.color = piece_data["color"]
    design_piece.save!
  end
end
