import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../core/services/ai_assistant_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/pressable_scale.dart';

class AiAssistantScreen extends StatefulWidget {
  final bool showAppBar;
  const AiAssistantScreen({super.key, this.showAppBar = true});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Assalam-o-Alaikum! I am Dr. Imran Siddiqui, your HarvestHub Agricultural Advisor & Plant Doctor. Ask me about crop health, wheat sowing, tomato blight, mandi rates, or fertilizer requirements!',
      'isUser': false,
      'time': '10:30 AM',
    },
  ];

  void _sendMessage([String? presetQuery]) {
    final query = presetQuery ?? _inputController.text.trim();
    if (query.isEmpty) return;

    final nowTime = TimeOfDay.now().format(context);

    setState(() {
      _messages.add({
        'text': query,
        'isUser': true,
        'time': nowTime,
      });
      if (presetQuery == null) _inputController.clear();
      _isThinking = true;
    });

    _scrollToBottom();

    // Generate response from AI Assistant Service with natural expert typing delay
    final responseText = AiAssistantService.getResponse(query);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isThinking = false;
        _messages.add({
          'text': responseText,
          'isUser': false,
          'time': TimeOfDay.now().format(context),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              leading: const AppBackButton(),
              titleSpacing: 0,
              title: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 28),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF52B788),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Imran Siddiqui',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Text(
                        'Agricultural Expert • Online',
                        style: TextStyle(fontSize: 11, color: Color(0xFFD8F3DC), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            children: [
              // Expert Badge Card (AgriCare style)
              if (!widget.showAppBar) _buildEmbeddedExpertHeader(),

              // Preset Suggested Prompt Chips
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPromptChip('🌾 Wheat Rust Treatment'),
                    _buildPromptChip('🍅 Tomato Leaf Curl Virus'),
                    _buildPromptChip('🌱 Urea & DAP Ratio'),
                    _buildPromptChip('🍊 Vitamin C Fruits'),
                    _buildPromptChip('🚜 Best Sowing Season'),
                    _buildPromptChip('📦 Mandi Pickup Timings'),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Messages List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isThinking) {
                      return _buildTypingIndicator();
                    }

                    final msg = _messages[index];
                    final isUser = msg['isUser'] as bool;
                    final text = msg['text'] as String;
                    final time = msg['time'] as String;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 8, bottom: 2),
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(Icons.psychology_alt_rounded, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 20),
                                  ),
                                  border: Border.all(
                                    color: isUser ? AppColors.primary : AppColors.cardBorder,
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1B4332).withValues(alpha: isUser ? 0.08 : 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : AppColors.textPrimary,
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          time,
                                          style: TextStyle(
                                            color: isUser ? Colors.white70 : AppColors.textLight,
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (isUser) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.done_all_rounded, size: 12, color: Color(0xFFD8F3DC)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.06, end: 0);
                  },
                ),
              ),

              // Pill-Shaped Floating Input Bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.eco_outlined, color: AppColors.primaryLight, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Ask Dr. Imran about crops, fertilizers...',
                                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textLight),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PressableScale(
                      onPressed: () => _sendMessage(),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmbeddedExpertHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dr. Imran Siddiqui',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
                Text(
                  'Agricultural Expert • 4.9 ★ (1.2k consultations)',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD8F3DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                SizedBox(width: 4),
                Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dr. Imran is typing',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 8),
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.2, 1.2), duration: 400.ms),
            const SizedBox(width: 3),
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.2, 1.2), duration: 400.ms, delay: 150.ms),
            const SizedBox(width: 3),
            Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.2, 1.2), duration: 400.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PressableScale(
        onPressed: () => _sendMessage(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B4332).withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
