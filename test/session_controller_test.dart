import 'package:flutter_test/flutter_test.dart';
import 'package:rehabunified_task/controllers/session_controller.dart';

void main() {
  late SessionController controller;

  setUp(() {
    // Note: In a real app, you would mock SessionService here
    controller = SessionController();
  });

  test('initial state is empty', () {
    expect(controller.allSessions.isEmpty, true);
    expect(controller.isInitialLoading.value, false);
  });

  test('changeStatus updates selectedStatus', () {
    controller.changeStatus('upcoming');
    expect(controller.selectedStatus.value, 'upcoming');
  });
}
