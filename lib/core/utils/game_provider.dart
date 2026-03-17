import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameState {
  final int hearts;
  final int xp;
  final int level;
  final Set<String> openedCards;

  GameState({
    required this.hearts,
    required this.xp,
    required this.level,
    required this.openedCards,
  });

  GameState copyWith({
    int? hearts,
    int? xp,
    int? level,
    Set<String>? openedCards,
  }) {
    return GameState(
      hearts: hearts ?? this.hearts,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      openedCards: openedCards ?? this.openedCards,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier()
      : super(GameState(
          hearts: 3,
          xp: 0,
          level: 1,
          openedCards: {},
        ));

  /// =========================
  /// ❤️ GAME OVER CHECK
  /// =========================
  bool isGameOver() {
    return state.hearts <= 0;
  }

  /// =========================
  /// 🔄 RESET TOTAL (jarang dipakai)
  /// =========================
  void resetGame() {
    state = GameState(
      hearts: 3,
      xp: 0,
      level: 1,
      openedCards: {},
    );
  }

  /// =========================
  /// 💀 GAME OVER (TAPI SIMPAN PROGRESS)
  /// =========================
  void gameOverButKeepProgress() {
    state = state.copyWith(
      hearts: 3, // reset nyawa saja
    );
  }

  /// =========================
  /// 🔓 UNLOCK NEXT LEVEL
  /// =========================
  void unlockNextLevel() {
    state = state.copyWith(
      level: state.level + 1,
    );
  }

  /// =========================
  /// 📚 OPEN LESSON CARD
  /// =========================
  void openCard(String title) {
    if (state.openedCards.contains(title)) return;

    final newSet = {...state.openedCards, title};

    state = state.copyWith(
      openedCards: newSet,
      xp: state.xp + 5,
    );
  }

  /// =========================
  /// ✅ JAWABAN BENAR
  /// =========================
  void correctAnswer() {
    state = state.copyWith(
      xp: state.xp + 10,
    );
  }

  /// =========================
  /// ❌ JAWABAN SALAH
  /// =========================
  void wrongAnswer() {
    state = state.copyWith(
      hearts: state.hearts - 1,
    );
  }

  /// =========================
  /// 📌 CHECK CARD
  /// =========================
  bool isCardOpened(String title) {
    return state.openedCards.contains(title);
  }

  bool isAllOpened(int total) {
    return state.openedCards.length >= total;
  }
}

/// =========================
/// PROVIDER
/// =========================
final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});