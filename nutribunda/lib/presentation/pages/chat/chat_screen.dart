import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/chat/typing_indicator.dart';

/// Screen untuk TanyaBunda AI chatbot
/// Requirements: 9.1, 9.2, 9.5, 9.6 - Chat interface, response time, disclaimer, conversation history
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize chat dengan disclaimer message
    // Requirements: 9.5 - Menampilkan peringatan di setiap sesi percakapan baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initializeChat();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// Scroll ke bawah untuk menampilkan pesan terbaru
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Handle pengiriman pesan
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Clear input field
    _textController.clear();

    // Send message
    context.read<ChatProvider>().sendMessage(text);

    // Scroll to bottom setelah pesan dikirim
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TanyaBunda AI'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Menu untuk restart conversation
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'restart') {
                _showRestartDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restart',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Mulai Percakapan Baru'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Error banner if there's an error
              if (chatProvider.errorMessage != null)
                _buildErrorBanner(chatProvider),
              
              // Chat messages area
              Expanded(
                child: _buildMessagesArea(chatProvider),
              ),
              
              // Typing indicator
              if (chatProvider.isLoading)
                const TypingIndicator(),
              
              // Input field
              ChatInputField(
                controller: _textController,
                onSend: _sendMessage,
                isLoading: chatProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build area untuk menampilkan pesan-pesan chat
  Widget _buildMessagesArea(ChatProvider chatProvider) {
    if (!chatProvider.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatProvider.messages.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada percakapan.\nSilakan ajukan pertanyaan seputar MPASI dan gizi ibu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        
        // Auto scroll ke bawah saat pesan baru ditambahkan
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (index == chatProvider.messages.length - 1) {
            _scrollToBottom();
          }
        });

        return ChatMessageBubble(
          message: message,
          key: ValueKey(message.id),
        );
      },
    );
  }

  /// Build error banner untuk menampilkan error message
  Widget _buildErrorBanner(ChatProvider chatProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red[50],
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatProvider.errorMessage!,
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () => chatProvider.clearError(),
            icon: Icon(
              Icons.close,
              color: Colors.red[700],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog untuk konfirmasi restart conversation
  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Percakapan Baru'),
        content: const Text(
          'Apakah Anda yakin ingin memulai percakapan baru? '
          'Riwayat percakapan saat ini akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatProvider>().restartConversation();
              _scrollToBottom();
            },
            child: const Text('Ya, Mulai Baru'),
          ),
        ],
      ),
    );
  }
}