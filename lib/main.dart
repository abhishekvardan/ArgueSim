import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'models.dart';
import 'api_service.dart';

final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

void main() {
  runApp(const ProviderScope(child: ArgueSimApp()));
}

class ArgueSimApp extends HookConsumerWidget {
  const ArgueSimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBored = ref.watch(isBoredModeProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      title: 'ArgueSim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isBored ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: isBored ? AppColors.joyBg : AppColors.obsidian,
        textTheme: GoogleFonts.outfitTextTheme(
          isBored ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
        ),
      ),
      home: isAuthenticated ? const MainChatScreen() : const PinEntryScreen(),
    );
  }
}

class PinEntryScreen extends HookConsumerWidget {
  const PinEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final errorText = useState<String?>(null);

    void authenticate() {
      if (pinController.text == 'Abhishek') {
        ref.read(isAuthenticatedProvider.notifier).state = true;
      } else {
        errorText.value = 'Incorrect PIN. Hint: User Name';
        pinController.clear();
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.obsidian,
              AppColors.obsidian.withBlue(40).withRed(20),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(
                    Icons.lock_person_outlined,
                    size: 80,
                    color: Colors.white24,
                  ).animate().fadeIn(duration: 1.seconds).scale(),
                  const SizedBox(height: 30),
                  Text(
                    'ArgueSim',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your PIN to continue',
                    style: TextStyle(color: Colors.white54),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 48),
                  Container(
                    maxWidth: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: pinController,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '••••',
                        hintStyle: TextStyle(color: Colors.white12),
                      ),
                      onSubmitted: (_) => authenticate(),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  if (errorText.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        errorText.value!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ).animate().shake(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(200, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Unlock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainChatScreen extends HookConsumerWidget {
  const MainChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final currentMode = ref.watch(argueModeProvider);
    final isThinking = ref.watch(isThinkingProvider);
    final isBored = ref.watch(isBoredModeProvider);
    final scrollController = useScrollController();
    final textController = useTextEditingController();

    // Auto-scroll to bottom
    useEffect(() {
      if (scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
      return null;
    }, [messages, isThinking]);

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow (Animated)
          if (!isBored)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentMode.color.withOpacity(0.1),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 5.seconds)
               .blur(begin: const Offset(50, 50), end: const Offset(100, 100)),
            ),

          SafeArea(
            child: Column(
              children: [
                const AppHeader(),

                // Chat Messages
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length + (isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const ThinkingIndicator();
                      }
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
                ),

                // Context Indicator (Fight Mode)
                if (ref.watch(isFightModeProvider) && ref.watch(customContextProvider) != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fight Mode: ${ref.watch(customContextProvider)}',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(isFightModeProvider.notifier).state = false;
                            ref.read(customContextProvider.notifier).state = null;
                          },
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.5),

                const ModeSelector(),
                InputArea(controller: textController),
              ],
            ),
          ),
          
          // "I am bored" Button
          if (!isBored)
            Positioned(
              bottom: 120,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _triggerJoyMode(ref),
                label: const Text('I am bored'),
                icon: const Icon(Icons.sentiment_very_satisfied),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ).animate().scale(delay: 1.seconds).shimmer(duration: 2.seconds),
            ),
        ],
      ),
    );
  }

  void _triggerJoyMode(WidgetRef ref) async {
    ref.read(isBoredModeProvider.notifier).state = true;
    ref.read(argueModeProvider.notifier).state = ArgueMode.joy;
    
    final currentHistory = ref.read(chatProvider);
    
    ref.read(chatProvider.notifier).addMessage(ChatMessage(
      text: "I'm bored! Make me laugh or tell me something cool.",
      isUser: true,
      mode: ArgueMode.joy,
    ));

    ref.read(isThinkingProvider.notifier).state = true;
    final aiResponse = await ref.read(apiServiceProvider).getDisagreement(
      "The user is bored. DO NOT ARGUE. Start a game, tell a joke, or engage them curiously and playfully!",
      ArgueMode.joy,
      history: currentHistory,
    );
    ref.read(isThinkingProvider.notifier).state = false;
    
    ref.read(chatProvider.notifier).addMessage(ChatMessage(
      text: aiResponse,
      isUser: false,
      mode: ArgueMode.joy,
    ));
  }
}

class AppHeader extends HookConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFightMode = ref.watch(isFightModeProvider);
    final isBored = ref.watch(isBoredModeProvider);
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'ArgueSim',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: isBored ? AppColors.joyTextPrimary : AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
              if (isFightMode)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Icon(Icons.local_fire_department, color: Colors.redAccent, size: 24),
                ).animate().scale().shake(),
              if (isBored)
                 const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                ).animate().scale().shimmer(),
            ],
          ),
          Row(
            children: [
              if (isBored)
                IconButton(
                  onPressed: () {
                    ref.read(isBoredModeProvider.notifier).state = false;
                    ref.read(argueModeProvider.notifier).state = ArgueMode.polite;
                  },
                  icon: const Icon(Icons.dark_mode_outlined, color: Colors.black54),
                  tooltip: 'Back to Reality',
                ),
              IconButton(
                onPressed: () => _showFightModeDialog(context, ref),
                icon: Icon(
                  Icons.sports_kabaddi, 
                  color: isFightMode ? Colors.redAccent : (isBored ? Colors.black38 : AppColors.textSecondary)
                ),
                tooltip: 'Fight Mode (Persona)',
              ),
              IconButton(
                onPressed: () => _showSafetyInfo(context),
                icon: Icon(Icons.info_outline, color: isBored ? Colors.black38 : AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSafetyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Safety Disclaimer', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ArgueSim is a "Thinking Mirror" designed for playful exploration of ideas. It intentionally disagrees to spark critical thinking.',
                  style: TextStyle(height: 1.4, color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text(
                  '⚠️ IMPORTANT:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                ),
                Text(
                  'Not for therapy. If you are in crisis, please speak with a professional.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                Text('• Crisis Line: 741741', style: TextStyle(color: Colors.white70)),
                Text('• Hotline: 988', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFightModeDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(customContextProvider));
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Conflict Context', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g., Optimist vs Cynic...',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(isFightModeProvider.notifier).state = false;
                ref.read(customContextProvider.notifier).state = null;
                Navigator.pop(context);
              },
              child: const Text('Reset', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(isFightModeProvider.notifier).state = true;
                  ref.read(customContextProvider.notifier).state = controller.text.trim();
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Fight!', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends HookConsumerWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBored = ref.watch(isBoredModeProvider);
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser 
              ? (isBored ? Colors.blue.withOpacity(0.08) : AppColors.glassWhite)
              : (isBored ? message.mode.color.withOpacity(0.08) : message.mode.color.withOpacity(0.15)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          border: Border.all(
            color: isUser 
                ? (isBored ? Colors.blue.withOpacity(0.1) : Colors.white10)
                : message.mode.color.withOpacity(isBored ? 0.1 : 0.3),
            width: 1,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isBored ? AppColors.joyTextPrimary : AppColors.textPrimary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
    );
  }
}

class ThinkingIndicator extends HookConsumerWidget {
  const ThinkingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(argueModeProvider);
    final isBored = ref.watch(isBoredModeProvider);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isBored ? Colors.black.withOpacity(0.03) : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Dot(color: mode.color, delay: 0),
            const SizedBox(width: 4),
            Dot(color: mode.color, delay: 200),
            const SizedBox(width: 4),
            Dot(color: mode.color, delay: 400),
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  final int delay;
  const Dot({super.key, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), delay: delay.ms, duration: 600.ms)
     .fadeIn(delay: delay.ms, duration: 600.ms);
  }
}

class ModeSelector extends HookConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(argueModeProvider);
    final isBored = ref.watch(isBoredModeProvider);

    // Hide other modes if in Joy mode? Or show all?
    // User asked "White mood or joy mood where ai tries interest..."
    // Let's keep all modes but highlight Joy if active.

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: ArgueMode.values.length,
        itemBuilder: (context, index) {
          final mode = ArgueMode.values[index];
          final isSelected = mode == currentMode;

          return GestureDetector(
            onTap: () {
              ref.read(argueModeProvider.notifier).state = mode;
              if (mode == ArgueMode.joy) {
                ref.read(isBoredModeProvider.notifier).state = true;
              } else {
                ref.read(isBoredModeProvider.notifier).state = false;
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? mode.color.withOpacity(isBored ? 0.1 : 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? mode.color : (isBored ? Colors.black12 : Colors.white10),
                  width: 1.5,
                ),
              ),
              child: Text(
                mode.displayName,
                style: TextStyle(
                  color: isSelected ? mode.color : (isBored ? Colors.black38 : AppColors.textSecondary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class InputArea extends HookConsumerWidget {
  final TextEditingController controller;
  const InputArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(argueModeProvider);
    final isThinking = ref.watch(isThinkingProvider);
    final isBored = ref.watch(isBoredModeProvider);

    void sendMessage() async {
      if (controller.text.trim().isEmpty || isThinking) return;

      final userText = controller.text.trim();
      final contextText = ref.read(customContextProvider);
      final currentHistory = ref.read(chatProvider);
      controller.clear();

      ref.read(chatProvider.notifier).addMessage(ChatMessage(
        text: userText,
        isUser: true,
        mode: mode,
      ));

      ref.read(isThinkingProvider.notifier).state = true;
      final aiResponse = await ref.read(apiServiceProvider).getDisagreement(
        userText, 
        mode, 
        customContext: contextText,
        history: currentHistory,
      );
      ref.read(isThinkingProvider.notifier).state = false;

      ref.read(chatProvider.notifier).addMessage(ChatMessage(
        text: aiResponse,
        isUser: false,
        mode: mode,
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: isBored ? Colors.black.withOpacity(0.05) : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: isBored ? Colors.black12 : Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    style: TextStyle(color: isBored ? Colors.black : Colors.white),
                    decoration: InputDecoration(
                      hintText: isBored ? 'Ask me anything!' : 'Share a thought...',
                      hintStyle: TextStyle(color: isBored ? Colors.black38 : AppColors.textSecondary),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send_rounded, color: mode.color),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOut);
  }
}
