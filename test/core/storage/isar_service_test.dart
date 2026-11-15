import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:myfitness_journal/core/models/workout.dart';
import 'package:myfitness_journal/core/storage/isar_service.dart';
import 'package:myfitness_journal/core/storage/isar_workout_repository.dart';

void main() {
  late Directory directory;

  setUpAll(() async {
    final libraryExtension = Platform.isWindows
        ? 'dll'
        : Platform.isMacOS
        ? 'dylib'
        : 'so';
    final libraryPrefix = Platform.isWindows ? '' : 'lib';
    final libraryPath =
        '${Directory.systemTemp.path}${Platform.pathSeparator}'
        '${libraryPrefix}isar_community_3_4_1.$libraryExtension';
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): libraryPath},
      download: true,
    );
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('journal_isar_auth_');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'keeps offline records separate from users and restores both stores',
    () async {
      final service = IsarService(directoryProvider: () async => directory);
      final offline = await service.openOffline();
      final offlineRepository = IsarWorkoutRepository(offline);
      await offlineRepository.save(
        Workout(date: DateTime(2026, 1, 1), exercises: const []),
      );

      final accountA = await service.openForUser(
        '12345678-1234-1234-1234-123456789abc',
      );
      final accountB = await service.openForUser(
        'abcdefab-cdef-abcd-efab-cdefabcdefab',
      );
      final accountARepository = IsarWorkoutRepository(accountA);
      final accountBRepository = IsarWorkoutRepository(accountB);

      expect(await IsarWorkoutRepository(accountA).getAll(), isEmpty);
      expect(await accountBRepository.getAll(), isEmpty);
      await accountARepository.save(
        Workout(date: DateTime(2026, 2, 1), exercises: const []),
      );

      expect(offline.name, Isar.defaultName);
      expect(accountA.name, 'user_12345678-1234-1234-1234-123456789abc');
      expect((await accountARepository.getAll()), hasLength(1));
      expect(await accountBRepository.getAll(), isEmpty);
      await service.closeAll();

      final reopenedService = IsarService(
        directoryProvider: () async => directory,
      );
      expect(
        await IsarWorkoutRepository(
          await reopenedService.openOffline(),
        ).getAll(),
        hasLength(1),
      );
      expect(
        await IsarWorkoutRepository(
          await reopenedService.openForUser(
            '12345678-1234-1234-1234-123456789abc',
          ),
        ).getAll(),
        hasLength(1),
      );
      expect(
        await IsarWorkoutRepository(
          await reopenedService.openForUser(
            'abcdefab-cdef-abcd-efab-cdefabcdefab',
          ),
        ).getAll(),
        isEmpty,
      );
      await reopenedService.closeAll();
    },
  );

  test('rejects database names that could escape the user scope', () async {
    final service = IsarService(directoryProvider: () async => directory);
    expect(() => service.openForUser('../offline'), throwsArgumentError);
    await service.closeAll();
  });
}
