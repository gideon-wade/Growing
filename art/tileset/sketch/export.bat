ffmpeg -i tileset.png -vf "scale=1028:1028:force_original_aspect_ratio=decrease,pad=1028:1028:(ow-iw)/2:(oh-ih)/2" tileset1028.png -y
