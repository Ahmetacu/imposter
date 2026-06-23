import 'dart:math';

import '../data/word_pool.dart';
import '../models/game_session.dart';
import '../models/player.dart';
import '../models/word_pack_id.dart';

/// Oyun oturumu oluşturma ve doğrulama mantığı.
abstract final class GameEngine {
  /// Oyuncu sayısı geçerli mi? (en az 3)
  static bool isValidPlayerCount(int count) =>
      count >= WordPool.minPlayers && count <= WordPool.maxPlayers;

  /// Oyuncu isimlerini normalize eder; boş isimler varsayılan alır.
  static List<String> normalizePlayerNames(List<String> names) {
    return List.generate(names.length, (i) {
      final trimmed = names[i].trim();
      return trimmed.isEmpty ? 'Oyuncu ${i + 1}' : trimmed;
    });
  }

  /// Yeni oyun oturumu oluşturur.
  ///
  /// - [playerNames] en az 3 oyuncu içermeli
  /// - Rastgele bir oyuncu impostor seçilir
  /// - Impostor dışındaki herkes aynı gizli kelimeyi görür
  /// - Impostor kelime görmez (ekranda Impostor uyarısı)
  static GameSession createSession({
    required List<String> playerNames,
    required WordPackId packId,
    Random? random,
  }) {
    final rng = random ?? Random();
    final names = normalizePlayerNames(playerNames);

    if (names.length < WordPool.minPlayers) {
      throw ArgumentError(
        'En az ${WordPool.minPlayers} oyuncu gerekli, ${names.length} verildi.',
      );
    }

    final impostorIndex = rng.nextInt(names.length);
    final pack = WordPool.packById(packId);
    final secretWord = pack.words[rng.nextInt(pack.words.length)];

    final players = List.generate(
      names.length,
      (i) => Player(
        name: names[i],
        isImpostor: i == impostorIndex,
      ),
    );

    return GameSession(
      players: players,
      secretWord: secretWord,
      category: pack.name,
      packId: packId,
      impostorIndex: impostorIndex,
    );
  }

  /// Varsayılan isimlerle hızlı oturum (test / demo).
  static GameSession createDemoSession({
    int playerCount = 4,
    WordPackId? packId,
    Random? random,
  }) {
    final rng = random ?? Random();
    final count = playerCount.clamp(WordPool.minPlayers, WordPool.maxPlayers);
    final names = List.generate(count, (i) => 'Oyuncu ${i + 1}');
    final selectedPack = packId ?? WordPackId.values[rng.nextInt(WordPackId.values.length)];

    return createSession(
      playerNames: names,
      packId: selectedPack,
      random: rng,
    );
  }
}
