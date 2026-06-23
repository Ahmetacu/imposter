import 'dart:math';

import '../data/word_pool_data.dart';
import '../models/word_pack.dart';
import '../models/word_pack_id.dart';

/// Tüm kelime paketlerine erişim ve rastgele kelime seçimi.
abstract final class WordPool {
  static const minPlayers = 3;
  static const maxPlayers = 12;

  static final List<WordPack> _packs = [
    WordPack(
      id: WordPackId.generalCulture,
      name: WordPackId.generalCulture.displayName,
      words: List.unmodifiable(WordPoolData.generalCulture),
    ),
    WordPack(
      id: WordPackId.foods,
      name: WordPackId.foods.displayName,
      words: List.unmodifiable(WordPoolData.foods),
    ),
    WordPack(
      id: WordPackId.movies,
      name: WordPackId.movies.displayName,
      words: List.unmodifiable(WordPoolData.movies),
    ),
  ];

  static List<WordPack> get allPacks => List.unmodifiable(_packs);

  static WordPack packById(WordPackId id) =>
      _packs.firstWhere((p) => p.id == id);

  static WordPack? tryPackById(WordPackId id) {
    for (final pack in _packs) {
      if (pack.id == id) return pack;
    }
    return null;
  }

  /// Belirtilen paketten rastgele kelime döner.
  static String randomWordFromPack(WordPackId packId, {Random? random}) {
    final rng = random ?? Random();
    final pack = packById(packId);
    return pack.words[rng.nextInt(pack.words.length)];
  }

  /// Rastgele bir paketten rastgele kelime döner.
  static ({WordPack pack, String word}) randomWord({Random? random}) {
    final rng = random ?? Random();
    final pack = _packs[rng.nextInt(_packs.length)];
    final word = pack.words[rng.nextInt(pack.words.length)];
    return (pack: pack, word: word);
  }

  static int totalWordCount() =>
      _packs.fold(0, (sum, pack) => sum + pack.wordCount);
}
