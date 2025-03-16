ffmpeg -i tileset_hex_2048.png -vf "scale=1024:1024:force_original_aspect_ratio=decrease,pad=1024:1024:(ow-iw)/2:(oh-ih)/2" tileset_hex_1024.png -y
