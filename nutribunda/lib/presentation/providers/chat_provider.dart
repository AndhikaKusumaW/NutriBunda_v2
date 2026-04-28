import 'package:flutter/foundation.dart';
import '../../core/services/chat_service.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/chat_message.dart';

/// Provider untuk mengelola state TanyaBunda AI chat
/// Requirements: 9.1, 9.2, 9.6 - Chat interface, response time, conversation history
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  // Conversation state
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  ChatProvider({required ChatService chatService})
      : _chatService = chatService;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get hasMessages => _messages.isNotEmpty;

  /// Initialize chat dengan disclaimer message
  /// Requirements: 9.5 - Menampilkan peringatan di setiap sesi percakapan baru
  void initializeChat() {
    if (_isInitialized) return;

    _messages = [
      ChatMessage.ai(ChatService.getDisclaimerMessage()),
    ];
    _isInitialized = true;
    notifyListeners();
  }

  /// Mengirim pesan ke AI
  /// Requirements: 9.2 - Mengirim pertanyaan dan menampilkan respons < 10 detik
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Clear previous error
    _errorMessage = null;

    // Add user message
    final userMessage = ChatMessage.user(message.trim());
    _messages.add(userMessage);
    notifyListeners();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Get conversation history (exclude disclaimer message)
      final history = _messages
          .where((msg) => msg.content != ChatService.getDisclaimerMessage())
          .toList();

      // Send to Gemini API
      final response = await _chatService.sendMessage(
        message.trim(),
        history.sublist(0, history.length - 1), // Exclude current message
      );

      // Add AI response
      final aiMessage = ChatMessage.ai(response);
      _messages.add(aiMessage);
    } on ChatException catch (e) {
      // Requirements: 9.4 - Menampilkan pesan kesalahan yang informatif
      _errorMessage = ChatService.getErrorMessage(e);
      
      // Add error message to chat
      _messages.add(ChatMessage.ai(
        '❌ Maaf, terjadi kesalahan:\n\n$_errorMessage\n\nSilakan coba lagi.',
      ));
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
      
      _messages.add(ChatMessage.ai(
        '❌ Maaf, terjadi kesalahan yang tidak terduga.\n\nSilakan coba lagi.',
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear conversation history
  void clearConversation() {
    _messages.clear();
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Restart conversation dengan disclaimer baru
  void restartConversation() {
    clearConversation();
    initializeChat();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if conversation has any user messages (excluding disclaimer)
  bool get hasUserMessages {
    return _messages.any((msg) => 
      msg.isUser && msg.content != ChatService.getDisclaimerMessage());
  }

  /// Get the last user message
  String? get lastUserMessage {
    final userMessages = _messages.where((msg) => msg.isUser).toList();
    return userMessages.isNotEmpty ? userMessages.last.content : null;
  }

  /// Get conversation summary untuk debugging
  String getConversationSummary() {
    return '''
Total messages: ${_messages.length}
User messages: ${_messages.where((m) => m.isUser).length}
AI messages: ${_messages.where((m) => !m.isUser).length}
Is loading: $_isLoading
Has error: ${_errorMessage != null}
''';
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}
