import os
from PIL import Image

def process_icon(input_path, res_dir):
    img = Image.open(input_path).convert("RGBA")
    
    # Simple background removal for pure white(ish) isolation
    width, height = img.size
    pixels = img.load()
    
    min_x = width; min_y = height; max_x = 0; max_y = 0
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Tighten threshold to protect the beige faceplate (which is around 245/240/220)
            if a > 0 and not (r > 253 and g > 253 and b > 253):
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
            else:
                pixels[x, y] = (r, g, b, 0)
    
    # Crop to the actual object
    if max_x >= min_x and max_y >= min_y:
        img = img.crop((min_x, min_y, max_x+1, max_y+1))
    
    # Adaptive Icon safe zone is 66/108 (so about ~60% of the dimension)
    def create_and_save(size, out_path_fg, out_path_legacy, out_path_round):
        # Foreground transparent
        fg = Image.new("RGBA", (size, size), (0,0,0,0))
        # Determine scale - we use 0.45 to keep the rectangular radio within the safe zone
        scale = (size * 0.45) / max(img.width, img.height)
        scaled_img = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
        
        offset_x = (size - scaled_img.width) // 2
        offset_y = (size - scaled_img.height) // 2
        fg.paste(scaled_img, (offset_x, offset_y), scaled_img)
        fg.save(out_path_fg)
        
        # Legacy square
        bg_legacy = Image.new("RGBA", (size, size), (255,255,255,255))
        bg_legacy.paste(scaled_img, (offset_x, offset_y), scaled_img)
        bg_legacy.save(out_path_legacy)
        
        # Legacy round
        # Circle mask
        mask = Image.new("L", (size, size), 0)
        from PIL import ImageDraw
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size, size), fill=255)
        
        bg_round = Image.new("RGBA", (size, size), (255,255,255,0))
        bg_white_layer = Image.new("RGBA", (size, size), (255,255,255,255))
        bg_white_layer.paste(scaled_img, (offset_x, offset_y), scaled_img)
        bg_round.paste(bg_white_layer, (0, 0), mask)
        bg_round.save(out_path_round)

    configs = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192
    }
    
    # Clean old xml files
    os.system('find ' + res_dir + ' -name "ic_launcher*.xml" -delete')
    
    drawable_dir = os.path.join(res_dir, "drawable-anydpi-v26")
    if not os.path.exists(drawable_dir):
        # Let's use mipmap-anydpi-v26 instead
        drawable_dir = os.path.join(res_dir, "mipmap-anydpi-v26")
        if not os.path.exists(drawable_dir):
            os.makedirs(drawable_dir)
            
    # For actual drawables
    drawable_nodpi = os.path.join(res_dir, "drawable-nodpi")
    if not os.path.exists(drawable_nodpi):
        os.makedirs(drawable_nodpi)
        
    for dpi, size in configs.items():
        folder = os.path.join(res_dir, "mipmap-" + dpi)
        if not os.path.exists(folder):
            os.makedirs(folder)
            
        fg_path = os.path.join(folder, "ic_launcher_foreground.png")
        leg_path = os.path.join(folder, "ic_launcher.png")
        rnd_path = os.path.join(folder, "ic_launcher_round.png")
        
        create_and_save(size, fg_path, leg_path, rnd_path)
        
    # Also save a high-res version for splash screens
    splash_drawable_path = os.path.join(res_dir, "drawable", "ic_vintage_radio.png")
    if not os.path.exists(os.path.dirname(splash_drawable_path)):
        os.makedirs(os.path.dirname(splash_drawable_path))
    
    # Scale it nicely for splash (~240dp equivalent)
    # We use a smaller scale (0.5 instead of 0.8) to ensure the rectangular radio
    # doesn't hit the edges of the Android circular mask, making the "circle" less visible.
    splash_size = 512
    splash_img = Image.new("RGBA", (splash_size, splash_size), (0,0,0,0))
    scale = (splash_size * 0.5) / max(img.width, img.height)
    scaled_splash = img.resize((int(img.width * scale), int(img.height * scale)), Image.Resampling.LANCZOS)
    splash_img.paste(scaled_splash, ((splash_size - scaled_splash.width) // 2, (splash_size - scaled_splash.height) // 2), scaled_splash)
    splash_img.save(splash_drawable_path)
        
    # Create adaptive icon XMLs
    xml_content = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    with open(os.path.join(drawable_dir, "ic_launcher.xml"), 'w') as f:
        f.write(xml_content)
    with open(os.path.join(drawable_dir, "ic_launcher_round.xml"), 'w') as f:
        f.write(xml_content)

if __name__ == "__main__":
    input_img = "/Users/kundanprasad/.gemini/antigravity/brain/84baf862-7edc-4367-94b9-6f2442f095e3/orange_vintage_radio_icon_1776250580623.png"
    res_dir = "/Users/kundanprasad/code/rfm/android/app/src/main/res"
    process_icon(input_img, res_dir)
