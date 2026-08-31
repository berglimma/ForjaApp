#!/usr/bin/env python3
"""Remove magenta / pink studio backgrounds from avatar layers."""

from pathlib import Path

import numpy as np
from PIL import Image

SRC = Path("/Users/lindenbergbrito/.cursor/projects/Users-lindenbergbrito-Documents-ForjaApp/assets")
DST = Path("/Users/lindenbergbrito/Documents/ForjaApp/AvatarStudio.xcassets")

LAYERS = [
    "StudioBody_masc.png",
    "StudioBody_fem.png",
    "StudioChest_linen.png",
    "StudioChest_leather.png",
    "StudioChest_mail.png",
    "StudioChest_plate.png",
    "StudioChest_robe.png",
    "StudioChest_leather_fem.png",
    "StudioChest_plate_fem.png",
    "StudioChest_robe_fem.png",
    "StudioCloak_wool.png",
    "StudioLegs_trousers.png",
    "StudioLegs_mail.png",
    "StudioHair_short.png",
    "StudioHair_long.png",
    "StudioHair_braids.png",
    "StudioBeard_full.png",
    "StudioHead_helm.png",
    "StudioHead_hood.png",
]


def key_array(arr: np.ndarray) -> np.ndarray:
    rgb = arr[..., :3].astype(np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    magenta = np.sqrt((r - 255) ** 2 + (g - 0) ** 2 + (b - 255) ** 2)
    pink = np.sqrt((r - 220) ** 2 + (g - 90) ** 2 + (b - 180) ** 2)
    dist = np.minimum(magenta, pink)
    hot = (r > 150) & (b > 130) & (g < np.minimum(r, b) * 0.82) & ((r + b) - 2 * g > 80)
    amount = np.zeros(r.shape, dtype=np.float32)
    amount = np.where(dist < 70, 1.0, amount)
    amount = np.where((dist >= 70) & (dist < 115), (115 - dist) / 45, amount)
    amount = np.where(hot, np.maximum(amount, 0.92), amount)
    alpha = arr[..., 3].astype(np.float32) * (1.0 - np.clip(amount, 0, 1))
    out = arr.copy()
    out[..., 3] = alpha.astype(np.uint8)
    return out


CONTENTS = """{
  "images" : [
    {
      "filename" : "%s",
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "template-rendering-intent" : "original"
  }
}
"""

CATALOG = """{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""


def main() -> None:
    DST.mkdir(parents=True, exist_ok=True)
    (DST / "Contents.json").write_text(CATALOG)
    for name in LAYERS:
        src = SRC / name
        if not src.exists():
            print(f"missing {src}")
            continue
        im = Image.open(src).convert("RGBA")
        keyed = Image.fromarray(key_array(np.array(im)), "RGBA")
        stem = Path(name).stem
        imageset = DST / f"{stem}.imageset"
        imageset.mkdir(parents=True, exist_ok=True)
        keyed.save(imageset / name, "PNG")
        (imageset / "Contents.json").write_text(CONTENTS % name)
        print(f"keyed {name}")


if __name__ == "__main__":
    main()
