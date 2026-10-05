import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cultivatec_flutter/core/utils/celebrations.dart';
import 'package:cultivatec_flutter/core/utils/progress_service.dart';
import 'package:cultivatec_flutter/core/utils/sound_service.dart';
import 'package:cultivatec_flutter/core/widgets/cartoon_button.dart';
import 'package:cultivatec_flutter/core/widgets/living_wokov.dart';
import 'package:cultivatec_flutter/core/widgets/password_checklist.dart';
import 'package:cultivatec_flutter/core/widgets/wokov_mascot.dart';
import 'package:cultivatec_flutter/screens/simulators/arm_kinematics_simulator_screen.dart';
import 'package:cultivatec_flutter/screens/simulators/pid_simulator_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Sin audio ni vibración en las pruebas.
    await SoundService.setEnabled(false);
  });

  group('Wokov', () {
    test('todas las poses tienen su imagen en assets/images/wokov', () {
      for (final pose in WokovPose.values) {
        expect(File(pose.asset).existsSync(), isTrue, reason: 'Falta ${pose.asset}');
      }
    });
  });

  group('LivingWokov', () {
    test('existen todas las capas de animación y están declaradas en pubspec', () {
      for (final n in ['body', 'arm_l', 'arm_r', 'head', 'mouth', 'sprout', 'eye_closed']) {
        expect(File('assets/images/wokov/layers/$n.webp').existsSync(), isTrue, reason: 'Falta la capa $n');
      }
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('assets/images/wokov/layers/'), isTrue,
          reason: 'Las carpetas de assets no son recursivas: hay que declarar layers/');
    });

    testWidgets('se construye, anima y se destruye sin errores', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Center(child: LivingWokov(size: 200, idleAction: WokovAction.wave))),
      ));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(LivingWokov), findsOneWidget);
      // Quita el widget para cancelar timers y controladores.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('Assets de Wokov', () {
    test('existen los 20 retratos de expresiones', () {
      for (final f in WokovFace.values) {
        expect(File(f.asset).existsSync(), isTrue, reason: 'Falta ${f.asset}');
      }
    });

    test('existe el GIF de ensamblaje', () {
      expect(File('assets/images/wokov/robot_ensamblaje.gif').existsSync(), isTrue);
    });
  });

  group('ArmKinematicsSimulatorScreen', () {
    testWidgets('se construye y muestra las lecturas X, Y y Alcance', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ArmKinematicsSimulatorScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(find.text('Alcance'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(4));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('PidSimulation (la física del simulador)', () {
    test('solo P se queda corta: error permanente', () {
      final t = PidSimulation.trajectory(1.2, 0, 0);
      expect(t.last, inInclusiveRange(0.5, 0.6));
    });

    test('P + I elimina el error y llega a la meta', () {
      final t = PidSimulation.trajectory(1.2, 1.5, 0);
      expect((t.last - 1.0).abs(), lessThan(0.02));
    });

    test('demasiada P se pasa de la meta (overshoot)', () {
      final t = PidSimulation.trajectory(6, 0, 0);
      expect(t.reduce((a, b) => a > b ? a : b), greaterThan(1.2));
    });

    test('D amortigua las oscilaciones', () {
      final sinD = PidSimulation.trajectory(6, 0, 0).reduce((a, b) => a > b ? a : b);
      final conD = PidSimulation.trajectory(6, 0, 1.2).reduce((a, b) => a > b ? a : b);
      expect(conD, lessThan(sinD));
    });

    test('PID bien afinado llega rápido y sin pasarse', () {
      final t = PidSimulation.trajectory(3, 2, 1.0);
      expect(t.reduce((a, b) => a > b ? a : b), lessThan(1.02));
      expect(t.last, greaterThan(0.98));
    });

    test('reset vuelve a cero', () {
      final sim = PidSimulation();
      for (var i = 0; i < 100; i++) {
        sim.step();
      }
      expect(sim.value, greaterThan(0));
      sim.reset();
      expect(sim.value, 0);
      expect(sim.history.length, 1);
    });
  });

  group('PidSimulatorScreen', () {
    testWidgets('se construye, corre la simulación y se destruye sin errores', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PidSimulatorScreen()));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Valor'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(3));
      expect(find.text('Solo P'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('PasswordChecklist', () {
    testWidgets('marca las reglas obligatorias cumplidas', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PasswordChecklist(password: 'robot1234'))));
      await tester.pump(const Duration(milliseconds: 500));
      // 8 caracteres + letra + número (sin mayúsculas, que es opcional).
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    });

    testWidgets('sin contraseña no marca nada', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PasswordChecklist(password: ''))));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.text('Seguridad'), findsOneWidget);
    });
  });

  group('CartoonButton', () {
    testWidgets('ejecuta onPressed al tocarlo', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CartoonButton(text: 'Hola', onPressed: () => taps++)),
      ));
      await tester.tap(find.text('HOLA'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('deshabilitado no responde', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CartoonButton(text: 'Hola'))));
      await tester.tap(find.text('HOLA'));
      await tester.pump();
      expect(find.text('HOLA'), findsOneWidget);
    });
  });

  group('DailyGoalService', () {
    test('suma XP, detecta cuándo se cumple la meta y marca el día activo', () async {
      await DailyGoalService.init();
      await DailyGoalService.setGoal(30);
      final startXp = DailyGoalService.todayXp.value;
      final needed = 30 - startXp;

      if (needed > 1) {
        expect(DailyGoalService.addXp(1), isFalse);
      }
      expect(DailyGoalService.addXp(30), isTrue, reason: 'cruza la meta por primera vez');
      expect(DailyGoalService.addXp(5), isFalse, reason: 'ya estaba cumplida');
      expect(DailyGoalService.goalReachedToday, isTrue);
      expect(DailyGoalService.progress, 1.0);
      expect(DailyGoalService.weekActivity()[DailyGoalService.todayIndex], isTrue);
      expect(DailyGoalService.addXp(0), isFalse);
    });
  });

  group('CelebrationService', () {
    test('respeta el orden de llegada', () {
      CelebrationService.clear();
      CelebrationService.push(const Celebration(kind: CelebrationKind.levelUp, title: 'A', subtitle: ''));
      CelebrationService.push(const Celebration(kind: CelebrationKind.achievement, title: 'B', subtitle: ''));
      expect(CelebrationService.pop()!.title, 'A');
      expect(CelebrationService.pop()!.title, 'B');
      expect(CelebrationService.pop(), isNull);
      expect(CelebrationService.hasPending, isFalse);
    });
  });
}
