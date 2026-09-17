"""행궁다과 길 안내 지도 배경을 만든다.

지도 캡처(가로 3330px 네이버 지도 화면)에서 도로·건물 모양만 뽑아
앱 팔레트로 다시 칠한다. 글자·아이콘·경로선은 지우고, 이름표와 경로는
앱(store_directions_sheet.dart)이 그 위에 그린다.

    python tool/build_route_map.py ~/Downloads/naver_map.png

필요 패키지: pillow, numpy, scipy
좌표는 캡처를 가로 2000px로 줄인 기준이다. 앱의 `_MapGeo`와 같은 값을 쓴다.
"""

import sys

import numpy as np
from PIL import Image
from scipy import ndimage

# 캡처(2000px 기준)에서 잘라 쓸 영역. 앱의 _MapGeo.crop과 같아야 한다.
CROP = (520, 0, 1640, 1194)
OUT_SIZE = (1280, 1365)

# 목적지·출발 건물을 찾는 점 (2000px 기준)
DEST_POINT = (1100, 200)
START_POINT = (1235, 845)

ROAD, GROUND, BUILDING, SHOP, PLAZA, DEST, START = range(7)

# 앱 팔레트 (app_colors.dart에서 가져옴)
FILL = {
    ROAD: (255, 252, 249),
    GROUND: (236, 231, 225),
    BUILDING: (226, 220, 213),
    SHOP: (238, 226, 214),
    PLAZA: (229, 225, 219),
    DEST: (245, 228, 232),
    START: (233, 236, 224),
}
EDGE = {
    BUILDING: (205, 197, 189),
    SHOP: (214, 196, 176),
    DEST: (135, 61, 86),
    START: (141, 155, 105),
}


def _disk(radius):
    y, x = np.ogrid[-radius : radius + 1, -radius : radius + 1]
    return x * x + y * y <= radius * radius


def classify(rgb):
    r, g, b = (rgb[..., i].astype(int) for i in range(3))
    cls = np.full(r.shape, -1, dtype=int)
    cls[(r == 255) & (g == 255) & (b == 255)] = ROAD
    cls[(r == 253) & (g == 253) & (b == 253)] = BUILDING
    cls[(r == 250) & (g == 241) & (b == 231)] = SHOP
    grey = (abs(r - g) <= 1) & (abs(g - b) <= 1)
    cls[grey & (r >= 248) & (r <= 250)] = GROUND
    cls[grey & (r >= 240) & (r <= 242)] = PLAZA
    cls[(r == 241) & (g == 238) & (b == 236)] = PLAZA
    cls[(r == 244) & (g == 241) & (b == 239)] = PLAZA
    return cls


def main(path):
    src = Image.open(path).convert("RGB")
    scale = src.width / 2000
    box = tuple(round(v * scale) for v in CROP)
    rgb = np.asarray(src.crop(box))
    cls = classify(rgb)

    # 아이콘 원·글자 테두리도 흰색이라 도로로 읽힌다. 도로는 폭이 넓고 서로
    # 이어져 있으므로, 얇은 흰 부분을 깎아 낸 뒤 큰 덩어리만 도로로 남긴다.
    road = cls == ROAD
    disk = _disk(round(9 * scale))
    opened = ndimage.binary_opening(road, structure=disk)
    parts, count = ndimage.label(opened)
    sizes = ndimage.sum(opened, parts, range(1, count + 1))
    keep = np.isin(parts, 1 + np.flatnonzero(sizes > 4500 * scale * scale))
    road_kept = ndimage.binary_dilation(keep, structure=disk) & road
    cls[road & ~road_kept] = -1

    # 글자·아이콘·경로선 자리는 가장 가까운 분류로 메운다.
    unknown = cls < 0
    _, (iy, ix) = ndimage.distance_transform_edt(unknown, return_indices=True)
    cls = cls[iy, ix]

    # 계단 모양을 줄이기 위해 분류별로 흐리게 한 뒤 가장 큰 값을 고른다.
    classes = [ROAD, GROUND, BUILDING, SHOP, PLAZA]
    stack = np.stack(
        [ndimage.gaussian_filter((cls == c).astype(float), 2.2) for c in classes]
    )
    cls = np.array(classes)[stack.argmax(axis=0)]

    # 글자 자리에 남은 작은 조각은 주변 분류로 흡수한다.
    min_area = 900 * scale * scale
    for c in classes:
        parts, count = ndimage.label(cls == c)
        if count == 0:
            continue
        sizes = ndimage.sum(np.ones_like(parts), parts, range(1, count + 1))
        small = np.isin(parts, 1 + np.flatnonzero(sizes < min_area))
        cls[small] = -1
    buildings = (cls == BUILDING) | (cls == SHOP)
    holes = ndimage.binary_fill_holes(buildings) & ~buildings
    cls[holes] = -1
    unknown = cls < 0
    _, (iy, ix) = ndimage.distance_transform_edt(unknown, return_indices=True)
    cls = cls[iy, ix]

    # 출발·도착 건물을 따로 칠한다.
    buildings = (cls == BUILDING) | (cls == SHOP)
    labels, _ = ndimage.label(buildings)
    for point, target in ((DEST_POINT, DEST), (START_POINT, START)):
        x = round((point[0] - CROP[0]) * scale)
        y = round((point[1] - CROP[1]) * scale)
        label = labels[y, x]
        if label == 0:
            raise SystemExit(f"{point}에 건물이 없다")
        shape = ndimage.binary_opening(
            labels == label, structure=_disk(round(7 * scale))
        )
        cls[labels == label] = GROUND
        cls[shape] = target

    out = np.zeros(cls.shape + (3,), dtype=np.uint8)
    for c, color in FILL.items():
        out[cls == c] = color

    # 건물 테두리
    for c, color in EDGE.items():
        mask = cls == c
        inner = ndimage.binary_erosion(mask, iterations=3 if c in (DEST, START) else 2)
        out[mask & ~inner] = color

    Image.fromarray(out).resize(OUT_SIZE, Image.LANCZOS).save(
        "assets/map/route_map.png", optimize=True
    )
    print("assets/map/route_map.png")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "naver_map.png")
