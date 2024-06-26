import 'package:ecommerce_app/src/features/authentication/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../mocks.dart';
import '../../auth_robot.dart';

void main() {
  testWidgets('Cancel Logout', (tester) async {
    final r = AuthRobot(tester);
    await r.pumpAccountScreen();
    await r.tapLogoutButton();
    r.expectLogoutDialogFound();
    await r.tapCancelButton();
    r.expectLogoutDialogNotFound();
  });

  // TODO : Fix this test

  // testWidgets('Confirm Logout, Success', (tester) async {
  //   final r = AuthRobot(tester);

  //   await tester.runAsync(() async {
  //     await r.pumpAccountScreen();
  //     await r.tapLogoutButton(pumpOnly: true);
  //     r.expectLogoutDialogFound();
  //     await r.tapDialogLogoutButton(pumpOnly: true);
  //     await tester.pumpAndSettle();
  //     r.expectLogoutDialogNotFound();
  //     r.expectErrorAlertNotFound();
  //   });
  // });

  testWidgets('Confirm Logout, Failure', (tester) async {
    final r = AuthRobot(tester);
    final authRepository = MockAuthRepository();
    final exception = Exception('Connection Failed');
    when(authRepository.signOut).thenThrow(exception);
    when(authRepository.authStateChanges).thenAnswer(
      (_) => Stream.value(
        const AppUser(uid: '123', email: 'test@test.com'),
      ),
    );
    await r.pumpAccountScreen(authRepository: authRepository);
    await r.tapLogoutButton();
    r.expectLogoutDialogFound();
    await r.tapDialogLogoutButton();
    r.expectErrorAlertFound();
  });

  testWidgets('Confirm Logout, Loading State', (tester) async {
    final r = AuthRobot(tester);
    final authRepository = MockAuthRepository();
    when(authRepository.signOut).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 1)),
    );
    when(authRepository.authStateChanges).thenAnswer(
      (_) => Stream.value(
        const AppUser(uid: '123', email: 'test@test.com'),
      ),
    );
    await tester.runAsync(() async {
      await r.pumpAccountScreen(authRepository: authRepository);
      await r.tapLogoutButton();
      r.expectLogoutDialogFound();
      await r.tapDialogLogoutButton(pumpOnly: true);
      r.expectCircularProgressIndicator();
    });
  });
}
