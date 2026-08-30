import 'package:flutter_test/flutter_test.dart';
import 'package:tumbuhapp/features/pengukuran/data/pengukuran_service.dart';
import 'package:tumbuhapp/features/pengukuran/providers/pengukuran_provider.dart';
import 'package:tumbuhapp/shared/models/insight_model.dart';

InsightModel _insight(InsightStatus status, {String? text}) {
  return InsightModel(
    status: status,
    insightTeks: text,
    insightGeneratedAt: null,
  );
}

class _FakeGateway implements InsightGateway {
  final List<Object> responses;
  int calls = 0;

  _FakeGateway(this.responses);

  @override
  Future<InsightModel> getInsight(int pengukuranId) async {
    final response = responses[calls.clamp(0, responses.length - 1)];
    calls += 1;
    if (response is Error) throw response;
    if (response is Exception) throw response;
    return response as InsightModel;
  }
}

void main() {
  test('polling pending dan processing berhenti ketika completed', () async {
    final gateway = _FakeGateway([
      _insight(InsightStatus.pending),
      _insight(InsightStatus.processing),
      _insight(InsightStatus.completed, text: 'Insight selesai'),
    ]);
    final controller = InsightController(
      pengukuranId: 12,
      gateway: gateway,
      delay: (_) async {},
    );

    await controller.load();

    expect(gateway.calls, 3);
    expect(controller.state.insight?.status, InsightStatus.completed);
    expect(controller.state.insight?.insightTeks, 'Insight selesai');
    expect(controller.state.isPolling, isFalse);
  });

  test('polling berhenti setelah batas waktu dan menyediakan refresh',
      () async {
    final gateway = _FakeGateway([_insight(InsightStatus.processing)]);
    final controller = InsightController(
      pengukuranId: 12,
      gateway: gateway,
      maxPollingDuration: Duration.zero,
      delay: (_) async {},
    );

    await controller.load();

    expect(gateway.calls, 1);
    expect(controller.state.pollingTimedOut, isTrue);
    await controller.refresh();
    expect(gateway.calls, 2);
  });

  test('failed menjadi state terminal tanpa polling', () async {
    final gateway = _FakeGateway([_insight(InsightStatus.failed)]);
    final controller = InsightController(
      pengukuranId: 12,
      gateway: gateway,
      delay: (_) async {},
    );

    await controller.load();

    expect(gateway.calls, 1);
    expect(controller.state.insight?.status, InsightStatus.failed);
  });

  test('superseded menjadi state terminal tanpa polling', () async {
    final gateway = _FakeGateway([_insight(InsightStatus.superseded)]);
    final controller = InsightController(
      pengukuranId: 12,
      gateway: gateway,
      delay: (_) async {},
    );

    await controller.load();

    expect(gateway.calls, 1);
    expect(controller.state.insight?.status, InsightStatus.superseded);
    expect(controller.state.isPolling, isFalse);
    expect(controller.state.pollingTimedOut, isFalse);
  });

  test('network error ditampilkan eksplisit dan tidak menjadi insight kosong',
      () async {
    final gateway = _FakeGateway([Exception('Jaringan terputus')]);
    final controller = InsightController(
      pengukuranId: 12,
      gateway: gateway,
      delay: (_) async {},
    );

    await controller.load();

    expect(controller.state.errorMessage, contains('Jaringan terputus'));
    expect(controller.state.insight, isNull);
    expect(controller.state.isLoading, isFalse);
  });
}
