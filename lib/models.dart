import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

enum ArgueMode {
  polite,
  sarcastic,
  philosophical,
  absurd,
  joy,
  perspective;

  String get displayName {
    switch (this) {
      case ArgueMode.polite: return 'Polite';
      case ArgueMode.sarcastic: return 'Sarcastic';
      case ArgueMode.philosophical: return 'Philosophical';
      case ArgueMode.absurd: return 'Absurd';
      case ArgueMode.joy: return 'Joy';
      case ArgueMode.perspective: return 'Perspective';
    }
  }

  Color get color {
    switch (this) {
      case ArgueMode.polite: return const Color(0xFF00E5FF);
      case ArgueMode.sarcastic: return const Color(0xFFFFAB40);
      case ArgueMode.philosophical: return const Color(0xFFD1C4E9);
      case ArgueMode.absurd: return const Color(0xFFB2FF59);
      case ArgueMode.joy: return const Color(0xFFFFD600);
      case ArgueMode.perspective: return const Color(0xFF81C784);
    }
  }

  String get systemPrompt {
    const brevityConstraint = " Be extremely concise. Keep your response under 2 sentences (max 40 words).";
    switch (this) {
      case ArgueMode.polite:
        return "Argue against the user's statement with extreme politeness. Use phrases like 'While I understand the logic behind...', then offer a counter-perspective. End with a reflective question.$brevityConstraint";
      case ArgueMode.sarcastic:
        return "Argue against the user's statement using sharp sarcasm and wit. Be a bit cynical. Use humor to point out logical fallacies or real-world contradictions.$brevityConstraint";
      case ArgueMode.philosophical:
        return "Argue against the user's statement by looking at it through an existential or abstract lens. Shift the focus from the practical to the eternal.$brevityConstraint";
      case ArgueMode.absurd:
        return "Argue against the user's statement using a completely bizarre and unrelated analogy. Connect something mundane to their thought.$brevityConstraint";
      case ArgueMode.joy:
        return "DO NOT ARGUE. You are now in 'Joy Mode'. Be extremely cheerful, playful, and engaging. Tell jokes, suggest fun games, or ask curious questions about the user's day. Your goal is to make the user smile and forget their boredom. Use emojis and stay concise.";
      case ArgueMode.perspective:
        return "You are a 'Wise Advisor'. When the user shares a project or idea, provide 2-3 different perspectives they might not have considered and highlight hidden challenges. Be moral, useful, and constructive. If asked for solutions, provide practical and ethical advice. Stay concise.";
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final ArgueMode mode;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.mode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

final argueModeProvider = StateProvider<ArgueMode>((ref) => ArgueMode.polite);
final customContextProvider = StateProvider<String?>((ref) => null);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

final isThinkingProvider = StateProvider<bool>((ref) => false);
final isFightModeProvider = StateProvider<bool>((ref) => false);
final isBoredModeProvider = StateProvider<bool>((ref) => false);
