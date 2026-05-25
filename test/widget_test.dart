import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:haenggung_dagwa_flutter/main.dart';
import 'package:haenggung_dagwa_flutter/models/recommendation.dart';
import 'package:haenggung_dagwa_flutter/services/recommendation_service.dart';

void main() {
  testWidgets('renders Haenggung Dagwa landing page', (tester) async {
    await tester.pumpWidget(const HaenggungDagwaApp());

    expect(find.text('행궁다과'), findsWidgets);
    expect(find.text('화성행궁 곁,\n명인이 빚은 다과.'), findsOneWidget);
    expect(find.text('체험 문의하기'), findsOneWidget);
  });

  testWidgets('opens Korean reservation date picker without errors', (
    tester,
  ) async {
    await tester.pumpWidget(const HaenggungDagwaApp());

    final dateField = find.text('날짜를 선택해 주세요');
    await Scrollable.ensureVisible(tester.element(dateField), alignment: 0.45);
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(of: dateField, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('renders main page at mobile and desktop widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in const [Size(390, 844), Size(1440, 1000)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(const HaenggungDagwaApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'viewport: $size');
      expect(find.text('행궁다과'), findsWidgets);
    }
  });

  test('recommendation service returns yakgwa for formal small gift', () {
    final service = RecommendationService();
    final result = service.getRecommendation(
      const RecommendationInput(
        personality: '차분히 음미하는 감각형',
        moment: '부모님과 함께해요',
        sweetness: '적당히 달콤한 맛',
        texture: '쫀득한 떡 식감',
        tea: '따뜻한 차와 함께',
        choiceStyle: '대표 메뉴를 고르는 편',
        situation: '교수님께 드릴 격식 있는 선물을 찾고 있어요',
      ),
    );

    expect(result.productName, '행궁약과');
    expect(result.dagwaType, '유밀과·모약과');
    expect(result.tags, contains('선물성'));
  });

  test('recommendation service returns bingsu for cool social dessert', () {
    final service = RecommendationService();
    final result = service.getRecommendation(
      const RecommendationInput(
        personality: '같이 나누는 E형',
        moment: '친구와 디저트를 먹어요',
        sweetness: '확실히 달콤한 맛',
        texture: '시원하게 녹는 식감',
        tea: '차보다 시원한 메뉴',
        choiceStyle: '보기 좋은 메뉴가 좋음',
        situation: '친구와 행궁동 산책 후 시원한 빙수를 먹고 싶어요',
      ),
    );

    expect(result.productName, '망고빙수');
    expect(result.secondaryMenuName, isNotEmpty);
  });

  test('recommendation service returns hwajeon for visual seasonal taste', () {
    final service = RecommendationService();
    final result = service.getRecommendation(
      const RecommendationInput(
        personality: '이야기와 의미를 좋아하는 직관형',
        moment: '수원 여행 기념이에요',
        sweetness: '은은하고 담백한 단맛',
        texture: '부드럽고 촉촉한 식감',
        tea: '상큼하고 산뜻하게',
        choiceStyle: '보기 좋은 메뉴가 좋음',
        situation: '사진으로 남길 예쁜 꽃 디저트가 먹고 싶어요',
      ),
    );

    expect(result.productName, '진달래화전');
    expect(result.dagwaType, '화전');
    expect(result.tags, contains('사진성'));
  });

  test('recommendation service returns yakgwa for warm deep taste', () {
    final service = RecommendationService();
    final result = service.getRecommendation(
      const RecommendationInput(
        personality: '조용히 머무는 I형',
        moment: '혼자 쉬고 싶어요',
        sweetness: '쌉싸름하고 깊은 맛',
        texture: '부드럽고 촉촉한 식감',
        tea: '한방차처럼 깊게',
        choiceStyle: '익숙하고 안정적인 메뉴',
        situation: '조용히 앉아서 진한 한방차를 마시고 싶어요',
      ),
    );

    expect(result.productName, '행궁약과');
    expect(result.dagwaType, '유밀과·모약과');
    expect(result.tags, contains('한방 향'));
  });

  test('recommendation service does not return tray as primary menu', () {
    final service = RecommendationService();
    final result = service.getRecommendation(defaultRecommendationInput);

    expect(result.productName, isNot('다과상'));
    expect(result.dagwaType, isNot('모둠 다과'));
  });
}
