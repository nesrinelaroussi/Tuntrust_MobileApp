import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../api_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  String? _conversationId;
  String? _conversationTitle;
  String _userName = '';

  List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const List<_SuggestionChip> _suggestions = [
    _SuggestionChip(
      icon: Icons.verified_user_rounded,
      label: 'What is ID-Trust?',
    ),
    _SuggestionChip(
      icon: Icons.shield_rounded,
      label: 'Certificat Wildcard SSL',
    ),
    _SuggestionChip(
      icon: Icons.description_rounded,
      label: 'كيف يمكنني الحصول على Enterprise-ID؟',
    ),
    _SuggestionChip(
      icon: Icons.fingerprint_rounded,
      label: 'n7eb n\'عرف signature electronique',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = await ApiService.getUser();

    if (!mounted) return;

    setState(() {
      final name = (user?['name'] as String? ?? '').trim();

      _userName = name.isNotEmpty ? name.split(' ').first : '';
    });
  }

  bool get _isEmptyState => _messages.isEmpty;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewConversation() {
    if (_isLoading) return;

    setState(() {
      _conversationId = null;
      _conversationTitle = null;
      _messages = [];
    });
  }

  Future<void> _loadConversation(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _chatService.getConversation(id);

      final rawMessages =
          details['messages'] as List<dynamic>? ?? [];

      final String title =
          details['title'] ?? 'Assistant TunTrust';

      final List<_ChatMessage> loaded = [];

      for (final m in rawMessages) {
        loaded.add(
          _ChatMessage(
            text: m['text'] ?? '',
            isUser: m['isUser'] ?? false,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _conversationId = id;
        _conversationTitle = title;
        _messages = loaded;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de charger la conversation : '
                '${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _openHistory() async {
    if (_isLoading) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );

    if (result == 'NEW') {
      _startNewConversation();
    } else if (result is String) {
      _loadConversation(result);
    }
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _controller.text).trim();

    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _isLoading = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {
      final responseData = await _chatService.askQuestion(
        text,
        conversationId: _conversationId,
      );

      final answer = responseData['answer'] ?? '';

      final String? newId =
      responseData['conversationId'];

      final String? newTitle =
      responseData['title'];

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: answer.toString(),
            isUser: false,
          ),
        );

        if (_conversationId == null && newId != null) {
          _conversationId = newId;
          _conversationTitle = newTitle;
        }

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;

      final errorMessage =
      error.toString().replaceFirst('Exception: ', '');

      setState(() {
        _messages.add(
          _ChatMessage(
            text: errorMessage,
            isUser: false,
            isError: true,
          ),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────
            // HEADER
            // ─────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.cardWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.borderColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _AnimatedAIAvatar(
                    isProcessing: _isLoading,
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          _conversationTitle ??
                              'Assistant TunTrust',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                        ),

                        Text(
                          _isLoading
                              ? 'En train d\'écrire...'
                              : 'En ligne',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: _isLoading
                                ? AppTheme.primaryGreen
                                : AppTheme
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppTheme.primaryGreen,
                    ),
                    tooltip:
                    'Nouvelle conversation',
                    onPressed: _isLoading
                        ? null
                        : _startNewConversation,
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.history_rounded,
                      color: AppTheme.textPrimary,
                    ),
                    tooltip: 'Historique',
                    onPressed:
                    _isLoading ? null : _openHistory,
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // BODY
            // ─────────────────────────────────────────────────────────────
            Expanded(
              child: _isEmptyState
                  ? _EmptyStateWidget(
                userName: _userName,
              )
                  : ListView.builder(
                controller: _scrollController,
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  12,
                ),
                itemCount:
                _messages.length +
                    (_isLoading ? 1 : 0),
                itemBuilder:
                    (context, index) {
                  if (_isLoading &&
                      index ==
                          _messages.length) {
                    return const Padding(
                      padding:
                      EdgeInsets.only(
                        bottom: 12,
                      ),
                      child:
                      _TypingIndicator(),
                    );
                  }

                  final message =
                  _messages[index];

                  // No flutter_animate here.
                  return _ChatBubble(
                    message: message,
                  );
                },
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // INPUT AREA
            // ─────────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset:
                    const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Suggestion chips
                  SingleChildScrollView(
                    scrollDirection:
                    Axis.horizontal,
                    child: Row(
                      children:
                      _suggestions.map(
                            (chip) {
                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              right: 8,
                            ),
                            child: InkWell(
                              onTap: _isLoading
                                  ? null
                                  : () =>
                                  _sendMessage(
                                    chip.label,
                                  ),
                              borderRadius:
                              BorderRadius
                                  .circular(30),
                              child: Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration:
                                BoxDecoration(
                                  color: AppTheme
                                      .surfaceLight,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    30,
                                  ),
                                  border:
                                  Border.all(
                                    color: AppTheme
                                        .borderColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  children: [
                                    Icon(
                                      chip.icon,
                                      color: AppTheme
                                          .primaryGreen,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      chip.label,
                                      style: Theme.of(
                                        context,
                                      )
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                        fontSize:
                                        12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                          _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction:
                          TextInputAction.send,
                          onSubmitted:
                          _isLoading
                              ? null
                              : (_) =>
                              _sendMessage(),
                          decoration:
                          InputDecoration(
                            hintText:
                            'Posez votre question à l\'assistant TunTrust…',
                            contentPadding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(24),
                              borderSide:
                              const BorderSide(
                                color: AppTheme
                                    .borderColor,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme
                                .surfaceLight,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        decoration:
                        BoxDecoration(
                          color: _isLoading
                              ? Colors.grey
                              : AppTheme
                              .primaryGreen,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () =>
                              _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userName.isNotEmpty
                  ? 'Hello $userName 👋'
                  : 'Hello 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w800,
                color:
                AppTheme.textPrimary,
              ),
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              'How can I help you today?',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                color:
                AppTheme.textSecondary,
                fontWeight:
                FontWeight.w500,
              ),
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────────────────────────────────
            // LOTTIE ANIMATION
            // ─────────────────────────────────────────────────────────
            Lottie.asset(
              'assets/Ai Robot Vector Art.json',
              width: 260,
              height: 260,
              repeat: true,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    this.color,
  });

  final _ChatMessage message;
  final Color? color;

  bool get _isArabic =>
      RegExp(r'[\u0600-\u06FF]')
          .hasMatch(message.text);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isError
        ? const Color(0xFFFEF2F2)
        : (message.isUser
        ? AppTheme.primaryGreen
        : color ?? AppTheme.cardWhite);

    final textColor = message.isError
        ? const Color(0xFFDC2626)
        : (message.isUser
        ? Colors.white
        : AppTheme.textPrimary);

    final borderColor = message.isError
        ? const Color(0xFFFCA5A5)
        : (message.isUser
        ? AppTheme.primaryGreen
        : AppTheme.borderColor);

    return Align(
      alignment: message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.only(bottom: 12),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        constraints:
        BoxConstraints(
          maxWidth:
          MediaQuery.of(context)
              .size
              .width *
              0.85,
        ),
        decoration:
        BoxDecoration(
          color: bubbleColor,
          borderRadius:
          BorderRadius.only(
            topLeft:
            const Radius.circular(18),
            topRight:
            const Radius.circular(18),
            bottomLeft:
            Radius.circular(
              message.isUser
                  ? 18
                  : 4,
            ),
            bottomRight:
            Radius.circular(
              message.isUser
                  ? 4
                  : 18,
            ),
          ),
          border:
          Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow:
          AppTheme.cardShadow,
        ),
        child:
        Directionality(
          textDirection: _isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          child:
          SelectableText(
            message.text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              color:
              textColor,
              height: 1.5,
              fontWeight:
              message.isError
                  ? FontWeight
                  .w500
                  : FontWeight
                  .normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT MESSAGE
// ─────────────────────────────────────────────────────────────────────────────

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final bool isError;
}

// ─────────────────────────────────────────────────────────────────────────────
// SUGGESTION CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionChip {
  const _SuggestionChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED AI AVATAR
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedAIAvatar
    extends StatefulWidget {
  const _AnimatedAIAvatar({
    required this.isProcessing,
  });

  final bool isProcessing;

  @override
  State<_AnimatedAIAvatar> createState() =>
      _AnimatedAIAvatarState();
}

class _AnimatedAIAvatarState
    extends State<_AnimatedAIAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(
        milliseconds: 1200,
      ),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return AnimatedBuilder(
      animation:
      _pulseController,
      builder: (_, __) {
        final scale =
        widget.isProcessing
            ? (1.0 +
            (_pulseController
                .value *
                0.15))
            : 1.0;

        final glow =
        widget.isProcessing
            ? (0.3 +
            (_pulseController
                .value *
                0.4))
            : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding:
            const EdgeInsets.all(
              10,
            ),
            decoration:
            BoxDecoration(
              gradient:
              AppTheme.heroGradient,
              shape:
              BoxShape.circle,
              boxShadow: [
                if (widget
                    .isProcessing)
                  BoxShadow(
                    color: AppTheme
                        .primaryGreen
                        .withOpacity(
                      glow,
                    ),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child:
            const Icon(
              Icons
                  .smart_toy_rounded,
              color:
              Colors.white,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPING INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _TypingIndicator
    extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() =>
      _TypingIndicatorState();
}

class _TypingIndicatorState
    extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<
      AnimationController>
  _controllers;

  late List<Animation<double>>
  _animations;

  @override
  void initState() {
    super.initState();

    _controllers =
        List.generate(
          3,
              (index) {
            return AnimationController(
              vsync: this,
              duration:
              const Duration(
                milliseconds: 600,
              ),
            );
          },
        );

    _animations =
        _controllers.map(
              (controller) {
            return Tween<double>(
              begin: 0.0,
              end: -8.0,
            ).animate(
              CurvedAnimation(
                parent: controller,
                curve:
                Curves.easeInOut,
              ),
            );
          },
        ).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;

      await Future.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!mounted) return;

      _controllers[i]
          .repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller
    in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Align(
      alignment:
      Alignment.centerLeft,
      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        decoration:
        BoxDecoration(
          color:
          AppTheme.cardWhite,
          borderRadius:
          const BorderRadius.only(
            topLeft:
            Radius.circular(18),
            topRight:
            Radius.circular(18),
            bottomLeft:
            Radius.circular(4),
            bottomRight:
            Radius.circular(18),
          ),
          border:
          Border.all(
            color:
            AppTheme.borderColor,
            width: 1,
          ),
          boxShadow:
          AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children:
          List.generate(
            3,
                (index) {
              return AnimatedBuilder(
                animation:
                _animations[index],
                builder:
                    (context, child) {
                  return Transform.translate(
                    offset:
                    Offset(
                      0,
                      _animations[
                      index]
                          .value,
                    ),
                    child:
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 3,
                      ),
                      child:
                      Container(
                        width: 8,
                        height: 8,
                        decoration:
                        const BoxDecoration(
                          color: AppTheme
                              .primaryGreen,
                          shape:
                          BoxShape
                              .circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}