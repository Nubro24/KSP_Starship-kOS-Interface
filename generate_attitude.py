"""
Generate 0.1-degree attitude indicator images from the 0.png reference.
Rotates the vehicle in 0.1 increments using high-quality bicubic interpolation.
The horizon line is auto-detected and kept fixed (not rotated) in every frame.

kOS round(x, 1) returns integer for whole degrees (e.g. round(45.0, 1) = 45)
and float for fractional (e.g. round(45.3, 1) = 45.3).
So filenames: 0.png, 0.1.png, 0.2.png, ... 0.9.png, 1.png, 1.1.png, ...
"""
from PIL import Image
import os
import shutil

BASE = "D:/Games/Steam/steamapps/common/Kerbal Space Program/Ships/Script/starship_img"

FOLDERS = [
    ("ShipAttitude", 360, True),
    ("BoosterAttitude", 360, False),
    ("StackAttitude", 360, True),
    ("ShipStackAttitude", 360, True),
]


def detect_horizon(img):
    """Find full-width horizon rows and their pixel data."""
    w, h = img.size
    horizon_rows = {}
    for row in range(h):
        non_trans = sum(1 for x in range(w) if img.getpixel((x, row))[3] > 0)
        if non_trans >= w:
            # Save the entire row's pixel data
            horizon_rows[row] = [img.getpixel((x, row)) for x in range(w)]
    return horizon_rows


def make_vehicle_only(img, horizon_rows):
    """Return a copy of img with horizon rows made transparent."""
    vehicle = img.copy()
    w = vehicle.size[0]
    for row in horizon_rows:
        for x in range(w):
            vehicle.putpixel((x, row), (0, 0, 0, 0))
    return vehicle


def generate_rotations(folder_path, ref_image_path, max_deg, label):
    """Generate 0.1 degree rotation images with fixed horizon line."""
    ref = Image.open(ref_image_path)
    if ref.mode != "RGBA":
        ref = ref.convert("RGBA")

    w, h = ref.size

    # Detect and separate horizon line
    horizon_rows = detect_horizon(ref)
    if horizon_rows:
        print(f"  Horizon detected at row(s): {list(horizon_rows.keys())}")
        vehicle = make_vehicle_only(ref, horizon_rows)
    else:
        print(f"  No horizon line detected, rotating full image")
        vehicle = ref

    if max_deg == 91:
        total = 901  # 0.0 to 90.0 inclusive
    else:
        total = 3600  # 0.0 to 359.9

    print(f"  Generating {total} images for {label}...")

    for i in range(total):
        angle = round(i / 10.0, 1)

        # Rotate only the vehicle (no horizon)
        rotated_vehicle = vehicle.rotate(-angle, resample=Image.BICUBIC, expand=False, center=(w//2, h//2))

        if horizon_rows:
            # Create canvas, draw fixed horizon, composite vehicle on top
            canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))

            # Draw the fixed horizon rows
            for row, pixels in horizon_rows.items():
                for x in range(w):
                    canvas.putpixel((x, row), pixels[x])

            # Composite rotated vehicle on top of horizon
            canvas = Image.alpha_composite(canvas, rotated_vehicle)
        else:
            canvas = rotated_vehicle

        # kOS tostring: whole numbers -> "0", "1", "90" etc.
        # fractional -> "0.1", "45.3" etc.
        if angle == int(angle):
            filename = f"{int(angle)}.png"
        else:
            filename = f"{angle}.png"

        canvas.save(os.path.join(folder_path, filename), "PNG", optimize=True)

        if (i + 1) % 500 == 0:
            print(f"    {label}: {i+1}/{total} done")

    print(f"  {label}: {total} images generated!")


def process_folder(folder_name, max_deg, has_block2):
    folder_path = os.path.join(BASE, folder_name)
    archive_path = os.path.join(BASE, folder_name + "_original")

    print(f"\n{'='*60}")
    print(f"Processing: {folder_name}")
    print(f"  Original files -> {archive_path}")

    # Archive originals (skip if already archived from a previous run)
    if not os.path.exists(archive_path):
        os.makedirs(archive_path, exist_ok=True)
        for f in os.listdir(folder_path):
            src = os.path.join(folder_path, f)
            if f == "Block2":
                continue
            shutil.move(src, os.path.join(archive_path, f))
        print(f"  Originals archived.")
    else:
        # Clean existing generated files but keep Block2
        for f in os.listdir(folder_path):
            if f == "Block2":
                continue
            fp = os.path.join(folder_path, f)
            if os.path.isfile(fp):
                os.remove(fp)
        print(f"  Archive exists, cleaned generated files.")

    ref_path = os.path.join(archive_path, "0.png")
    if not os.path.exists(ref_path):
        print(f"  ERROR: {ref_path} not found!")
        return

    generate_rotations(folder_path, ref_path, max_deg, folder_name)

    # Handle Block2 subfolder
    if has_block2:
        block2_path = os.path.join(folder_path, "Block2")
        block2_archive = os.path.join(BASE, folder_name + "_Block2_original")

        if os.path.exists(block2_path):
            print(f"\n  Processing: {folder_name}/Block2")

            if not os.path.exists(block2_archive):
                os.makedirs(block2_archive, exist_ok=True)
                for f in os.listdir(block2_path):
                    shutil.move(os.path.join(block2_path, f), os.path.join(block2_archive, f))
                print(f"  Block2 originals archived.")
            else:
                for f in os.listdir(block2_path):
                    fp = os.path.join(block2_path, f)
                    if os.path.isfile(fp):
                        os.remove(fp)
                print(f"  Block2 archive exists, cleaned generated files.")

            block2_ref = os.path.join(block2_archive, "0.png")
            if not os.path.exists(block2_ref):
                print(f"  ERROR: {block2_ref} not found!")
                return

            # ShipAttitude/Block2 has 360 files, others have 91
            block2_count = len([f for f in os.listdir(block2_archive) if f.endswith('.png')])
            block2_max = 360 if block2_count > 100 else 91

            generate_rotations(block2_path, block2_ref, block2_max, folder_name + "/Block2")


if __name__ == "__main__":
    print("Attitude Indicator Image Generator")
    print("Generating 0.1 degree increment rotations from reference images")
    print("Fixed horizon line preserved in all frames")
    print(f"Output directory: {BASE}")

    for folder_name, max_deg, has_block2 in FOLDERS:
        process_folder(folder_name, max_deg, has_block2)

    print("\n" + "="*60)
    print("ALL DONE!")
    print("\nSummary:")
    for folder_name, max_deg, has_block2 in FOLDERS:
        folder_path = os.path.join(BASE, folder_name)
        count = len([f for f in os.listdir(folder_path) if f.endswith('.png')])
        print(f"  {folder_name}: {count} images")
        if has_block2:
            b2 = os.path.join(folder_path, "Block2")
            if os.path.exists(b2):
                b2count = len([f for f in os.listdir(b2) if f.endswith('.png')])
                print(f"  {folder_name}/Block2: {b2count} images")
    print("\nOriginal files backed up to *_original folders in starship_img/")
