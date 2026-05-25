const menuItems = [
  {
    ko: "다과상",
    en: "Traditional Sweets Tray",
    ja: "茶菓膳",
    category: "대표 다과",
    price: "7,000원",
    tag: "대표",
    symbol: "茶菓",
    descriptions: {
      ko: "영양찰떡, 약과, 정과류를 차와 함께 즐기기 좋은 대표 구성입니다.",
      en: "A signature tray of rice cake, yakgwa, and preserved roots for tea.",
      ja: "餅、薬菓、正果をお茶と一緒に楽しむ代表メニューです。",
    },
  },
  {
    ko: "진달래화전",
    en: "Azalea Flower Pancake",
    ja: "ツツジ花煎",
    category: "전통 디저트",
    price: "7,000원",
    tag: "화전",
    symbol: "花煎",
    descriptions: {
      ko: "식용꽃을 올려 계절감과 색감을 살린 전통 화전입니다.",
      en: "A delicate Korean flower pancake finished with edible blossoms.",
      ja: "食用花をのせ、季節感と色を楽しむ伝統の花煎です。",
    },
  },
  {
    ko: "쌍화차",
    en: "Ssanghwa Herbal Tea",
    ja: "双和茶",
    category: "전통차",
    price: "9,000원",
    tag: "한방차",
    symbol: "雙和",
    descriptions: {
      ko: "깊은 한방 향과 묵직한 여운으로 다과와 함께 마시기 좋은 차입니다.",
      en: "A deep herbal tea with a rich aroma, ideal with traditional sweets.",
      ja: "漢方の香りが深く、茶菓と相性のよい伝統茶です。",
    },
  },
  {
    ko: "대추차",
    en: "Jujube Tea",
    ja: "ナツメ茶",
    category: "전통차",
    price: "9,000원",
    tag: "따뜻함",
    symbol: "棗",
    descriptions: {
      ko: "진하게 우려낸 대추의 단맛과 부드러운 질감이 살아 있는 전통차입니다.",
      en: "A naturally sweet jujube tea with a warm traditional finish.",
      ja: "ナツメの深い甘みとやさしい口当たりが感じられる伝統茶です。",
    },
  },
  {
    ko: "생강차",
    en: "Ginger Tea",
    ja: "生姜茶",
    category: "전통차",
    price: "7,000원",
    tag: "차 페어링",
    symbol: "薑",
    descriptions: {
      ko: "맑고 알싸한 생강 향으로 단맛의 다과를 깔끔하게 정리해 줍니다.",
      en: "A clear ginger tea that refreshes the palate after sweet desserts.",
      ja: "しょうがの香りが甘い茶菓の後味をすっきり整えます。",
    },
  },
  {
    ko: "망고빙수",
    en: "Mango Bingsu",
    ja: "マンゴーかき氷",
    category: "빙수",
    price: "15,000원",
    tag: "계절",
    symbol: "氷",
    descriptions: {
      ko: "우유 얼음 위에 망고와 소스를 넉넉히 올린 계절 인기 메뉴입니다.",
      en: "A generous mango bingsu served over rich milk ice.",
      ja: "ミルク氷にマンゴーとソースをたっぷりのせた人気かき氷です。",
    },
  },
  {
    ko: "녹차빙수",
    en: "Green Tea Bingsu",
    ja: "抹茶かき氷",
    category: "빙수",
    price: "15,000원",
    tag: "녹차",
    symbol: "綠茶",
    descriptions: {
      ko: "녹차의 쌉싸름함과 우유 얼음의 고소함을 함께 살린 빙수입니다.",
      en: "A green tea bingsu balancing earthy notes with creamy milk ice.",
      ja: "抹茶のほろ苦さとミルク氷のまろやかさを楽しめます。",
    },
  },
  {
    ko: "수원약과",
    en: "Suwon Yakgwa",
    ja: "水原薬菓",
    category: "개별 다과",
    price: "매장 문의",
    tag: "수원",
    symbol: "藥果",
    descriptions: {
      ko: "행궁다과가 다시 알리고 싶은 수원의 전통 약과입니다. 판매 여부는 매장에 확인해 주세요.",
      en: "A local yakgwa story Haenggung Dagwa hopes to revive. Please check availability.",
      ja: "行宮茶菓が伝えたい水原の薬菓です。販売状況は店頭でご確認ください。",
    },
  },
];

const recommendationProfiles = {
  "다과상": {
    pairing: "대추차",
    profile: "차분한 전통파",
    summary: "여러 다과를 조금씩 천천히 맛보며 차와 함께 오래 머무르기 좋은 대표 구성입니다.",
    tags: ["대표 메뉴", "차 페어링", "부모님과 함께"],
    scores: {
      calm: 2,
      social: 2,
      detail: 2,
      story: 2,
      rest: 1,
      parents: 4,
      friends: 2,
      gift: 3,
      travel: 2,
      low: 1,
      medium: 3,
      high: 1,
      herbal: 1,
      chewy: 2,
      crisp: 1,
      smooth: 1,
      icy: 0,
      warm: 3,
      fresh: 1,
      deep: 2,
      cool: 0,
      signature: 4,
      safe: 3,
      new: 1,
      photo: 2,
    },
  },
  "진달래화전": {
    pairing: "생강차",
    profile: "섬세한 계절파",
    summary: "꽃을 올린 전통 화전처럼 색감과 계절감을 함께 즐기고 싶은 분께 어울립니다.",
    tags: ["계절감", "사진 좋은 메뉴", "담백함"],
    scores: {
      calm: 1,
      social: 2,
      detail: 3,
      story: 3,
      rest: 1,
      parents: 2,
      friends: 3,
      gift: 2,
      travel: 3,
      low: 3,
      medium: 2,
      high: 0,
      herbal: 0,
      chewy: 3,
      crisp: 0,
      smooth: 1,
      icy: 0,
      warm: 2,
      fresh: 3,
      deep: 0,
      cool: 0,
      signature: 1,
      safe: 1,
      new: 3,
      photo: 4,
    },
  },
  "쌍화차": {
    pairing: "행궁약과 또는 정과류",
    profile: "깊은 취향파",
    summary: "달콤함보다 깊은 향과 묵직한 여운을 좋아하는 분께 잘 맞는 전통차입니다.",
    tags: ["한방차", "깊은 향", "조용한 시간"],
    scores: {
      calm: 4,
      social: 0,
      detail: 3,
      story: 2,
      rest: 4,
      parents: 3,
      friends: 0,
      gift: 1,
      travel: 0,
      low: 1,
      medium: 0,
      high: 0,
      herbal: 4,
      chewy: 0,
      crisp: 0,
      smooth: 2,
      icy: 0,
      warm: 3,
      fresh: 0,
      deep: 5,
      cool: 0,
      signature: 0,
      safe: 2,
      new: 1,
      photo: 0,
    },
  },
  "대추차": {
    pairing: "다과상",
    profile: "온화한 휴식파",
    summary: "부드러운 단맛과 온기가 필요할 때 가장 안정적으로 쉬어갈 수 있는 선택입니다.",
    tags: ["따뜻함", "부드러운 단맛", "휴식"],
    scores: {
      calm: 4,
      social: 1,
      detail: 2,
      story: 1,
      rest: 4,
      parents: 3,
      friends: 0,
      gift: 1,
      travel: 0,
      low: 2,
      medium: 3,
      high: 0,
      herbal: 2,
      chewy: 0,
      crisp: 0,
      smooth: 4,
      icy: 0,
      warm: 5,
      fresh: 0,
      deep: 2,
      cool: 0,
      signature: 1,
      safe: 3,
      new: 0,
      photo: 0,
    },
  },
  "생강차": {
    pairing: "진달래화전",
    profile: "깔끔한 균형파",
    summary: "단맛을 깔끔하게 정리해 주는 알싸한 향을 좋아한다면 잘 맞는 차입니다.",
    tags: ["깔끔함", "차 페어링", "산뜻함"],
    scores: {
      calm: 2,
      social: 0,
      detail: 2,
      story: 1,
      rest: 3,
      parents: 1,
      friends: 1,
      gift: 0,
      travel: 0,
      low: 3,
      medium: 1,
      high: 0,
      herbal: 2,
      chewy: 0,
      crisp: 0,
      smooth: 1,
      icy: 0,
      warm: 4,
      fresh: 4,
      deep: 1,
      cool: 0,
      signature: 0,
      safe: 2,
      new: 1,
      photo: 0,
    },
  },
  "망고빙수": {
    pairing: "가벼운 차 또는 물",
    profile: "밝은 디저트파",
    summary: "확실히 달콤하고 시원한 만족감을 원할 때, 친구와 나누기 좋은 메뉴입니다.",
    tags: ["달콤함", "시원함", "함께 나누기"],
    scores: {
      calm: 0,
      social: 4,
      detail: 0,
      story: 1,
      rest: 0,
      parents: 0,
      friends: 5,
      gift: 0,
      travel: 1,
      low: 0,
      medium: 2,
      high: 5,
      herbal: 0,
      chewy: 0,
      crisp: 0,
      smooth: 3,
      icy: 5,
      warm: 0,
      fresh: 2,
      deep: 0,
      cool: 5,
      signature: 0,
      safe: 2,
      new: 2,
      photo: 3,
    },
  },
  "녹차빙수": {
    pairing: "생강차",
    profile: "쌉싸름한 산뜻파",
    summary: "녹차의 쌉싸름함과 우유 얼음의 고소함을 함께 즐기고 싶은 분께 추천합니다.",
    tags: ["녹차", "시원함", "담백한 단맛"],
    scores: {
      calm: 1,
      social: 3,
      detail: 2,
      story: 1,
      rest: 1,
      parents: 0,
      friends: 4,
      gift: 0,
      travel: 1,
      low: 2,
      medium: 3,
      high: 1,
      herbal: 2,
      chewy: 0,
      crisp: 0,
      smooth: 3,
      icy: 5,
      warm: 0,
      fresh: 3,
      deep: 1,
      cool: 5,
      signature: 0,
      safe: 1,
      new: 2,
      photo: 2,
    },
  },
  "수원약과": {
    pairing: "따뜻한 대추차",
    profile: "로컬 스토리파",
    summary: "수원 여행의 기억을 작게 담아가고 싶거나 전통 간식의 이야기를 좋아하는 분께 어울립니다.",
    tags: ["수원 이야기", "포장 문의", "전통 간식"],
    scores: {
      calm: 1,
      social: 1,
      detail: 1,
      story: 5,
      rest: 0,
      parents: 1,
      friends: 1,
      gift: 5,
      travel: 5,
      low: 0,
      medium: 2,
      high: 4,
      herbal: 0,
      chewy: 0,
      crisp: 4,
      smooth: 0,
      icy: 0,
      warm: 2,
      fresh: 0,
      deep: 0,
      cool: 0,
      signature: 2,
      safe: 1,
      new: 3,
      photo: 1,
    },
  },
};

const menuGrid = document.querySelector("[data-menu-grid]");
const tabs = document.querySelectorAll("[data-lang]");
const header = document.querySelector("[data-elevate]");
const recommender = document.querySelector("[data-recommender]");
const recommendResult = document.querySelector("[data-recommend-result]");
const contactForm = document.querySelector("[data-contact-form]");
const formNote = document.querySelector("[data-form-note]");

let activeLanguage = "ko";

function renderMenu() {
  if (!menuGrid) return;

  menuGrid.innerHTML = menuItems
    .map((item) => {
      const title = item[activeLanguage] || item.ko;
      const description = item.descriptions[activeLanguage] || item.descriptions.ko;

      return `
        <article class="menu-card" data-symbol="${item.symbol}">
          <div class="menu-meta">
            <span>${item.category}</span>
            <span>${item.tag}</span>
          </div>
          <div>
            <h3>${title}</h3>
            <p>${description}</p>
          </div>
          <footer>
            <span>${item.symbol}</span>
            <strong>${item.price}</strong>
          </footer>
        </article>
      `;
    })
    .join("");
}

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    activeLanguage = tab.dataset.lang;
    tabs.forEach((item) => item.classList.toggle("is-active", item === tab));
    renderMenu();
  });
});

window.addEventListener("scroll", () => {
  if (!header) return;
  header.classList.toggle("is-elevated", window.scrollY > 24);
});

recommender?.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = new FormData(recommender);
  const answers = [
    data.get("energy"),
    data.get("moment"),
    data.get("sweetness"),
    data.get("texture"),
    data.get("tea"),
    data.get("novelty"),
  ];
  const ranked = Object.entries(recommendationProfiles)
    .map(([name, profile]) => ({
      name,
      profile,
      score: answers.reduce((sum, answer) => sum + (profile.scores[answer] || 0), 0),
    }))
    .sort((a, b) => b.score - a.score);
  const { name, profile } = ranked[0];
  const secondary = ranked[1];

  recommendResult.innerHTML = `
    <span>취향 분석 결과</span>
    <strong>${name}</strong>
    <p class="result-profile">${profile.profile}</p>
    <p>${profile.summary}</p>
    <dl class="result-pairing">
      <div>
        <dt>함께 추천</dt>
        <dd>${profile.pairing}</dd>
      </div>
      <div>
        <dt>차선 메뉴</dt>
        <dd>${secondary.name}</dd>
      </div>
    </dl>
    <div class="result-tags">
      ${profile.tags.map((tag) => `<em>${tag}</em>`).join("")}
    </div>
  `;
});

contactForm?.addEventListener("submit", (event) => {
  event.preventDefault();
  const data = new FormData(contactForm);
  const type = data.get("type");
  const people = data.get("people") || "인원 미정";
  const phone = data.get("phone") || "연락처 미입력";
  const message = data.get("message") || "세부 요청 없음";

  formNote.textContent = `${type} · ${people} · ${phone} 기준으로 문의 내용이 정리되었습니다. 요청: ${message}`;
  formNote.classList.add("is-done");
});

renderMenu();
