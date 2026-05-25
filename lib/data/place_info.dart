import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PlacePhoto {
  const PlacePhoto({required this.url, required this.label});

  final String url;
  final String label;
}

class ActualMenuItem {
  const ActualMenuItem({
    required this.ko,
    required this.en,
    required this.ja,
    required this.koDescription,
    required this.enDescription,
    required this.jaDescription,
    required this.category,
    required this.price,
    required this.tag,
    required this.symbol,
    required this.accent,
  });

  final String ko;
  final String en;
  final String ja;
  final String koDescription;
  final String enDescription;
  final String jaDescription;
  final String category;
  final String price;
  final String tag;
  final String symbol;
  final Color accent;
}

class FeaturedMenu {
  const FeaturedMenu({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.accent,
    required this.motif,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final List<String> tags;
  final Color accent;
  final String motif;
}

const placeName = '행궁다과';
const placeCategory = '카페·디저트';
const placeRoadAddress = '경기 수원시 팔달구 행궁로 25 2층';
const placeLotAddress = '경기 수원시 팔달구 남창동 26-1';
const placePhone = '031-251-9030';
const placeNaverUrl = 'https://naver.me/Fy2FI8D4';
const placeInstagramUrl = 'https://www.instagram.com/haenggung_da_gwa_1';
const placeVisitorReviewText = '방문자 리뷰 1,074';
const placeBlogReviewText = '블로그 리뷰 181';
const placeTodayStatus = '월·수·목·금·일 10:00-21:00 / 토 10:00-22:00';
const placeRegularClosed = '매주 화요일 휴무';
const placeShortHours = '영업시간 변동 가능 · 방문 전 네이버 지도 확인';

const placeHighlights = ['화성행궁 옆 2층', '떡공예 명인 운영', '다과상·전통차', '빙수·포장 다과'];

const placePhotos = [
  PlacePhoto(
    url:
        'https://ldb-phinf.pstatic.net/20230513_107/1683970455964c5JIq_PNG/%B3%EC%C2%F7%BA%F9%BC%F6_%BA%B8%C1%A4.png',
    label: '녹차빙수',
  ),
  PlacePhoto(
    url:
        'https://ldb-phinf.pstatic.net/20240311_110/17100829736230Dn18_JPEG/Screenshot_20240310_230126_NAVER.jpg',
    label: '행궁다과 메뉴',
  ),
  PlacePhoto(
    url:
        'https://ldb-phinf.pstatic.net/20230513_151/1683970443745gBh2b_PNG/%C7%E0%B1%C3%B4%D9%B0%FA_%C7%C3%B7%B9%C0%CC%BD%BA1.png',
    label: '전통 다과',
  ),
  PlacePhoto(
    url:
        'https://ldb-phinf.pstatic.net/20230513_4/1683970449210aoyB2_PNG/%C7%E0%B1%C3%B4%D9%B0%FA_%C7%C3%B7%B9%C0%CC%BD%BA2.png',
    label: '다과 플레이스',
  ),
];

const actualMenuItems = [
  ActualMenuItem(
    ko: '다과상',
    en: 'Traditional Sweets Tray',
    ja: '茶菓膳',
    koDescription: '영양찰떡, 약과, 정과 등 명인이 빚은 전통 간식을 한 상으로 즐기는 대표 메뉴입니다.',
    enDescription:
        'A signature tray of Korean sweets such as rice cake, yakgwa, and preserved roots.',
    jaDescription: '栄養餅、薬菓、正果などを一緒に楽しむ代表的な茶菓膳です。',
    category: '대표 다과',
    price: '7,000원',
    tag: '대표',
    symbol: '茶菓',
    accent: AppColors.cinnabar,
  ),
  ActualMenuItem(
    ko: '진달래화전',
    en: 'Azalea Flower Pancake',
    ja: 'ツツジ花煎',
    koDescription: '식용꽃을 올려 계절감과 색감을 살린 전통 화전입니다.',
    enDescription:
        'A delicate Korean flower pancake topped with edible blossoms.',
    jaDescription: '食用花をのせ、季節感と色を楽しむ伝統の花煎です。',
    category: '전통 디저트',
    price: '7,000원',
    tag: '화전',
    symbol: '花煎',
    accent: AppColors.plum,
  ),
  ActualMenuItem(
    ko: '대추차',
    en: 'Jujube Tea',
    ja: 'ナツメ茶',
    koDescription: '진하게 우려낸 대추의 단맛과 부드러운 질감이 살아 있는 전통차입니다.',
    enDescription:
        'A deep, naturally sweet jujube tea with a warm traditional finish.',
    jaDescription: 'ナツメの深い甘みとやさしい口当たりが感じられる伝統茶です。',
    category: '전통차',
    price: '9,000원',
    tag: '따뜻함',
    symbol: '棗',
    accent: AppColors.brown,
  ),
  ActualMenuItem(
    ko: '쌍화차',
    en: 'Ssanghwa Herbal Tea',
    ja: '双和茶',
    koDescription: '쌉싸름하고 깊은 한방 향으로 다과와 함께 마시기 좋은 차입니다.',
    enDescription:
        'A deep herbal tea with a rich aroma, ideal with traditional sweets.',
    jaDescription: '漢方の香りが深く、茶菓と相性のよい伝統茶です。',
    category: '전통차',
    price: '9,000원',
    tag: '한방차',
    symbol: '雙和',
    accent: AppColors.gold,
  ),
  ActualMenuItem(
    ko: '생강차',
    en: 'Ginger Tea',
    ja: '生姜茶',
    koDescription: '맑고 알싸한 생강 향으로 단맛의 다과를 깔끔하게 정리해 줍니다.',
    enDescription:
        'A clear ginger tea that refreshes the palate after sweet desserts.',
    jaDescription: 'しょうがの香りが甘い茶菓の後味をすっきり整えます。',
    category: '전통차',
    price: '7,000원',
    tag: '차 페어링',
    symbol: '薑',
    accent: AppColors.jade,
  ),
  ActualMenuItem(
    ko: '망고빙수',
    en: 'Mango Bingsu',
    ja: 'マンゴーかき氷',
    koDescription: '우유 얼음 위에 망고와 소스를 넉넉히 올린 여름 인기 빙수입니다.',
    enDescription: 'A generous mango bingsu served over rich milk ice.',
    jaDescription: 'ミルク氷にマンゴーとソースをたっぷりのせた人気かき氷です。',
    category: '빙수',
    price: '15,000원',
    tag: '인기',
    symbol: '氷',
    accent: Color(0xFFD08A32),
  ),
  ActualMenuItem(
    ko: '녹차빙수',
    en: 'Green Tea Bingsu',
    ja: '抹茶かき氷',
    koDescription: '녹차의 쌉싸름함과 우유 얼음의 고소함을 함께 살린 빙수입니다.',
    enDescription:
        'A green tea bingsu balancing earthy tea notes with creamy milk ice.',
    jaDescription: '抹茶のほろ苦さとミルク氷のまろやかさを楽しめます。',
    category: '빙수',
    price: '15,000원',
    tag: '녹차',
    symbol: '綠茶',
    accent: AppColors.jade,
  ),
  ActualMenuItem(
    ko: '행궁약과',
    en: 'Haenggung Yakgwa',
    ja: '行宮薬菓',
    koDescription: '겹이 살아 있는 네모난 약과로, 다과상이나 선물용으로 곁들이기 좋습니다.',
    enDescription:
        'A layered square yakgwa suited for tea pairing or small gifts.',
    jaDescription: '層が感じられる四角い薬菓で、茶菓や手土産に合います。',
    category: '개별 다과',
    price: '2,500원',
    tag: '포장',
    symbol: '藥果',
    accent: AppColors.cinnabar,
  ),
];

const featuredMenus = [
  FeaturedMenu(
    id: 'dagwa-tray',
    name: '다과상',
    subtitle: '명인의 전통 과자 한 상',
    description: '영양찰떡, 행궁약과, 정과류를 차와 함께 즐기기 좋은 대표 구성입니다.',
    tags: ['대표 메뉴', '부모님과 함께', '전통 디저트'],
    accent: AppColors.cinnabar,
    motif: '茶菓',
  ),
  FeaturedMenu(
    id: 'mango-bingsu',
    name: '망고빙수',
    subtitle: '우유 얼음과 망고의 계절 메뉴',
    description: '넉넉한 망고와 진한 우유 얼음으로 행궁동 산책 후 나누기 좋은 빙수입니다.',
    tags: ['여름 인기', '친구와 함께', '시원한 맛'],
    accent: Color(0xFFD08A32),
    motif: '氷',
  ),
  FeaturedMenu(
    id: 'traditional-tea',
    name: '대추차·쌍화차',
    subtitle: '다과와 어울리는 깊은 전통차',
    description: '따뜻한 대추차와 쌍화차는 다과상과 함께 즐기기 좋은 행궁다과의 기본입니다.',
    tags: ['전통차', '어른 선호', '차 페어링'],
    accent: AppColors.brown,
    motif: '茶',
  ),
  FeaturedMenu(
    id: 'yakgwa-gift',
    name: '행궁약과·정과류',
    subtitle: '가볍게 담아 가는 전통 간식',
    description: '개별 포장 약과와 정과류는 화성행궁 방문 후 작은 선물로 고르기 좋습니다.',
    tags: ['포장 가능', '수원 기념', '가벼운 선물'],
    accent: AppColors.jade,
    motif: '禮',
  ),
];

final featuredMenuNameById = {
  for (final menu in featuredMenus) menu.id: menu.name,
};
