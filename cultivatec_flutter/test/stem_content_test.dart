import 'package:flutter_test/flutter_test.dart';
import 'package:cultivatec_flutter/data/static/stem_content.dart';

/// Guards the shape of the curriculum. The lesson data is hand-written, so
/// these tests catch typos (duplicate ids, quizzes without a valid answer)
/// before they reach a classroom.
void main() {
  group('stemAreas', () {
    test('is not empty', () {
      expect(stemAreas, isNotEmpty);
    });

    test('has unique area ids', () {
      final ids = stemAreas.map((a) => a.id).toSet();
      expect(ids.length, stemAreas.length);
    });

    test('every area has at least one lesson', () {
      for (final area in stemAreas) {
        expect(area.lessons, isNotEmpty, reason: 'El área "${area.id}" no tiene lecciones');
      }
    });

    test('lesson ids are unique within their area', () {
      for (final area in stemAreas) {
        final ids = area.lessons.map((l) => l.id).toList();
        expect(ids.toSet().length, ids.length, reason: 'El área "${area.id}" tiene ids de lección repetidos');
      }
    });

    test('every lesson has content cards and quiz questions', () {
      for (final area in stemAreas) {
        for (final lesson in area.lessons) {
          expect(lesson.cards, isNotEmpty, reason: '${area.id}/${lesson.id} no tiene tarjetas de contenido');
          expect(lesson.questions, isNotEmpty, reason: '${area.id}/${lesson.id} no tiene preguntas de quiz');
        }
      }
    });

    test('every quiz question points at a real option', () {
      for (final area in stemAreas) {
        for (final lesson in area.lessons) {
          for (final q in lesson.questions) {
            expect(q.options.length, greaterThanOrEqualTo(2),
                reason: '${area.id}/${lesson.id}/${q.id} necesita al menos 2 opciones');
            expect(q.correct, inInclusiveRange(0, q.options.length - 1),
                reason: '${area.id}/${lesson.id}/${q.id} apunta a una opción inexistente');
            expect(q.explanation, isNotEmpty, reason: '${area.id}/${lesson.id}/${q.id} no tiene explicación');
          }
        }
      }
    });

    test('a lesson with a practice declares its challenge', () {
      for (final area in stemAreas) {
        for (final lesson in area.lessons) {
          if (lesson.practiceType != PracticeType.none) {
            expect(lesson.challengeId, isNotNull, reason: '${area.id}/${lesson.id} tiene práctica pero no challengeId');
          }
        }
      }
    });
  });

  group('areaById', () {
    test('resolves every declared area', () {
      for (final area in stemAreas) {
        expect(areaById(area.id).id, area.id);
      }
    });

    test('falls back to the first area for an unknown id', () {
      expect(areaById('no-existe').id, stemAreas.first.id);
    });
  });
}
