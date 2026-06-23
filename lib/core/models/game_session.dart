import 'player.dart';
import 'word_pack_id.dart';

class GameSession {
  const GameSession({
    required this.players,
    required this.secretWord,
    required this.category,
    required this.packId,
    required this.impostorIndex,
  });

  final List<Player> players;
  final String secretWord;
  final String category;
  final WordPackId packId;
  final int impostorIndex;

  int get playerCount => players.length;

  Player playerAt(int index) => players[index];

  Player get impostor => players[impostorIndex];

  int get crewCount => playerCount - 1;

  /// Impostor dışındaki oyuncuların hepsi aynı kelimeyi görür.
  bool playerSeesWord(int index) => !players[index].isImpostor;
}
