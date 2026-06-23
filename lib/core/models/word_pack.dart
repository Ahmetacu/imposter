import 'word_pack_id.dart';

/// Tek bir kelime paketi — kategori adı ve kelime listesi.
class WordPack {
  const WordPack({
    required this.id,
    required this.name,
    required this.words,
  });

  final WordPackId id;
  final String name;
  final List<String> words;

  int get wordCount => words.length;
}
