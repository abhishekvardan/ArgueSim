import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'models.dart';

// Note: In a real app, you'd use a secure way to store the API key.
// For this simulation, we assume the user has set it or we use a placeholder.
const String _apiKey = String.fromEnvironment('API_KEY'); 

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  late final GenerativeModel? _model;

  ApiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemma-3-12b-it',
        apiKey: _apiKey,
      );
    } else {
      _model = null;
    }
  }

  Future<String> getDisagreement(
    String input, 
    ArgueMode mode, {
    String? customContext,
    List<ChatMessage> history = const [],
  }) async {
    if (_model == null) {
      return "API Key is missing. Please build the app with --dart-define=API_KEY=YOUR_KEY.";
    }
    String safetyInstruction = """
    IMPORTANT SAFETY RULE: If the user expresses severe mental distress, mentions self-harm, or seems to be in a genuine crisis, DO NOT DISAGREE. Instead, immediately switch to a supportive, empathetic tone and suggest they speak with a professional or reach out to a support line (like 988 in the US/Canada). Safety and well-being always come first.
    
    If the statement is NOT a crisis:
    You are ArgueSim, a 'Thinking Mirror' AI. Your goal is NOT to win a debate, but to help the user see their blind spots through intentional disagreement. ${mode.systemPrompt}
    """;
    
    String systemInstruction = safetyInstruction;
    
    if (customContext != null && customContext.isNotEmpty) {
      systemInstruction += "\nCURRENT CONTEXT: You are roleplaying. Adopt the persona: $customContext. However, still adhere to the SAFETY RULE above.";
    }

    final List<Content> contents = [
      Content.text(systemInstruction),
    ];

    // Add history (last 10 messages for context)
    final recentHistory = history.length > 10 
        ? history.sublist(history.length - 10) 
        : history;

    for (var msg in recentHistory) {
      if (msg.isUser) {
        contents.add(Content.model([TextPart("Understood. I will argue against: ${msg.text}")])); // Model acknowledgment of previous user state
        contents.add(Content.multi([TextPart("USER: ${msg.text}")]));
      } else {
        contents.add(Content.model([TextPart(msg.text)]));
      }
    }
    
    // The Gemini SDK Content.text() defaults to user role. 
    // For manual history we can just use text blocks with labels or proper Content objects.
    // Better: use Content.text for user and Content.model for AI.
    
    final finalContents = [
      Content.text(systemInstruction),
      ...recentHistory.map((msg) => msg.isUser 
          ? Content.text(msg.text) 
          : Content.model([TextPart(msg.text)])),
      Content.text(input),
    ];

    try {
      final response = await _model.generateContent(finalContents);
      return response.text ?? "I'm temporarily speechless, which is ironically a form of disagreement.";
    } catch (e) {
      return "Something went wrong in the matrix. Even the AI is confused by that statement.";
    }
  }
}
