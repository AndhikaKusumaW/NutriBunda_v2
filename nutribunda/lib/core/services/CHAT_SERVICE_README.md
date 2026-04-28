# ChatService - TanyaBunda AI Integration

## Overview

ChatService adalah komponen yang mengelola integrasi dengan Gemini API untuk fitur TanyaBunda AI chatbot. Service ini menyediakan antarmuka percakapan AI yang fokus pada domain gizi MPASI dan diet pemulihan ibu pasca-melahirkan.

## Requirements Coverage

### Requirement 9.1: Chat Interface
- ✅ Menyediakan antarmuka percakapan dalam Bahasa Indonesia
- ✅ Mengirim pertanyaan pengguna ke Gemini API

### Requirement 9.2: Response Time
- ✅ Mengirim pertanyaan beserta konteks sesi percakapan
- ✅ Menampilkan respons dalam waktu kurang dari 10 detik (timeout configured)

### Requirement 9.3: Topic Limitation
- ✅ Membatasi topik pada domain gizi MPASI, kesehatan bayi 6-24 bulan, dan diet ibu
- ✅ System prompt yang komprehensif untuk membatasi topik

### Requirement 9.4: Error Handling
- ✅ Menampilkan pesan kesalahan informatif untuk API failures
- ✅ Menyarankan pengguna memeriksa koneksi internet
- ✅ Handle timeout, network errors, rate limiting, dan invalid responses

### Requirement 9.5: Disclaimer
- ✅ Menampilkan peringatan bahwa respons AI bukan pengganti konsultasi medis

### Requirement 9.6: Conversation History
- ✅ Menyimpan riwayat percakapan sesi aktif
- ✅ Mengirim context history ke API untuk continuity

## Architecture

```
┌─────────────────────┐
│   ChatProvider      │  State Management
│   (Presentation)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   ChatService       │  Business Logic
│   (Core/Services)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Gemini API        │  External Service
│   (Google)          │
└─────────────────────┘
```

## Configuration

### API Key Setup

**IMPORTANT**: Sebelum menggunakan ChatService, Anda harus mengkonfigurasi Gemini API key.

#### Option 1: Environment Variable (Recommended for Production)
```dart
// Buat file .env di root project
GEMINI_API_KEY=your_actual_api_key_here

// Update api_constants.dart untuk membaca dari environment
static final String geminiApiKey = 
    const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
```

#### Option 2: Direct Configuration (Development Only)
```dart
// nutribunda/lib/core/constants/api_constants.dart
static const String geminiApiKey = 'your_actual_api_key_here';
```

**⚠️ WARNING**: Jangan commit API key ke version control!

### Get Gemini API Key

1. Kunjungi [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Login dengan Google account
3. Create new API key
4. Copy dan simpan API key dengan aman

## Usage

### Basic Usage

```dart
import 'package:nutribunda/core/services/chat_service.dart';
import 'package:nutribunda/data/models/chat_message.dart';

// Initialize service
final chatService = ChatService();

// Send message
try {
  final response = await chatService.sendMessage(
    'Apa itu MPASI?',
    [], // Empty history for first message
  );
  print('AI Response: $response');
} on ChatException catch (e) {
  print('Error: ${ChatService.getErrorMessage(e)}');
}
```

### With Provider (Recommended)

```dart
import 'package:provider/provider.dart';
import 'package:nutribunda/presentation/providers/chat_provider.dart';

// In your widget
class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Column(
          children: [
            // Display messages
            Expanded(
              child: ListView.builder(
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  return MessageBubble(message: message);
                },
              ),
            ),
            
            // Input field
            ChatInput(
              onSend: (text) => chatProvider.sendMessage(text),
              isLoading: chatProvider.isLoading,
            ),
          ],
        );
      },
    );
  }
}
```

### Initialize Chat with Disclaimer

```dart
// In initState or when screen opens
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ChatProvider>().initializeChat();
  });
}
```

## Features

### 1. System Prompt

ChatService menggunakan system prompt yang komprehensif untuk:
- Membatasi topik pada gizi MPASI dan diet ibu
- Memberikan panduan menjawab yang konsisten
- Mengarahkan kembali jika pertanyaan di luar topik
- Menyarankan konsultasi profesional untuk diagnosis medis

### 2. Conversation History Management

- Menyimpan hingga 10 pesan terakhir untuk efisiensi
- Mengirim context ke API untuk continuity percakapan
- Format yang kompatibel dengan Gemini API

### 3. Error Handling

Comprehensive error handling untuk berbagai skenario:

| Error Type | Description | User Message |
|------------|-------------|--------------|
| `networkError` | Tidak dapat terhubung ke API | "Tidak dapat terhubung ke server. Silakan periksa koneksi internet..." |
| `apiTimeout` | Request timeout (>10 detik) | "Permintaan memakan waktu terlalu lama. Silakan coba lagi." |
| `rateLimitExceeded` | Terlalu banyak request | "Terlalu banyak permintaan. Silakan tunggu beberapa saat..." |
| `apiKeyInvalid` | API key tidak valid | "Konfigurasi API tidak valid. Silakan hubungi administrator." |
| `invalidResponse` | Response format tidak valid | Custom message dari API |

### 4. Safety Settings

ChatService mengkonfigurasi safety settings untuk memblokir konten:
- Harassment
- Hate speech
- Sexually explicit content
- Dangerous content

### 5. Generation Config

Optimized untuk percakapan natural:
- Temperature: 0.7 (balanced creativity)
- Top K: 40
- Top P: 0.95
- Max Output Tokens: 1024

## Testing

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/services/chat_service_test.dart
flutter test test/presentation/providers/chat_provider_test.dart
```

### Test Coverage

- ✅ Successful API response
- ✅ Network timeout
- ✅ Connection error
- ✅ Rate limiting (429)
- ✅ Invalid response format
- ✅ Conversation history inclusion
- ✅ History limitation (max 10 messages)
- ✅ Error message formatting
- ✅ Provider state management
- ✅ Loading states
- ✅ Error recovery

### Manual Testing Checklist

- [ ] API key configured correctly
- [ ] First message shows disclaimer
- [ ] Messages appear in correct order
- [ ] Loading indicator shows during API call
- [ ] Error messages display correctly
- [ ] Network error handling works offline
- [ ] Conversation context maintained across messages
- [ ] Response time < 10 seconds
- [ ] AI stays on topic (MPASI/diet ibu)
- [ ] AI suggests professional consultation when appropriate

## Error Handling Examples

### Network Error
```dart
try {
  await chatProvider.sendMessage('Test');
} on ChatException catch (e) {
  if (e.type == ChatErrorType.networkError) {
    // Show retry button
    showRetryDialog();
  }
}
```

### Timeout Error
```dart
// Automatically handled by ChatProvider
// Error message added to chat
// User can retry by sending message again
```

### Rate Limit
```dart
// Automatically handled
// User sees message to wait before retrying
// Consider implementing exponential backoff
```

## Best Practices

### 1. API Key Security
- ❌ Never commit API key to version control
- ✅ Use environment variables
- ✅ Use secure storage for production
- ✅ Rotate keys regularly

### 2. Error Handling
- ✅ Always wrap API calls in try-catch
- ✅ Show user-friendly error messages
- ✅ Provide retry mechanisms
- ✅ Log errors for debugging

### 3. Performance
- ✅ Limit conversation history (max 10 messages)
- ✅ Use timeout (10 seconds)
- ✅ Show loading indicators
- ✅ Consider caching common responses

### 4. User Experience
- ✅ Show disclaimer at start
- ✅ Indicate when AI is typing
- ✅ Allow scrolling through history
- ✅ Provide clear error messages
- ✅ Enable conversation restart

## Troubleshooting

### Issue: "API key belum dikonfigurasi"
**Solution**: Update `geminiApiKey` in `api_constants.dart` with your actual API key.

### Issue: "Koneksi timeout"
**Possible Causes**:
- Slow internet connection
- Gemini API server issues
- Request too complex

**Solutions**:
- Check internet connection
- Retry the request
- Simplify the question

### Issue: "Terlalu banyak permintaan"
**Cause**: Rate limit exceeded

**Solutions**:
- Wait before retrying
- Implement request throttling
- Consider upgrading API quota

### Issue: Response tidak sesuai topik
**Cause**: System prompt tidak cukup kuat

**Solutions**:
- Review and strengthen system prompt
- Add more specific constraints
- Implement response validation

## Future Enhancements

### Planned Features
- [ ] Conversation persistence (save to local database)
- [ ] Export conversation history
- [ ] Voice input/output
- [ ] Multi-language support
- [ ] Suggested questions
- [ ] Response rating/feedback
- [ ] Offline mode with cached responses

### Performance Optimizations
- [ ] Response streaming (real-time typing effect)
- [ ] Request debouncing
- [ ] Response caching
- [ ] Conversation summarization for long histories

### Advanced Features
- [ ] Context-aware suggestions based on user profile
- [ ] Integration with food diary data
- [ ] Personalized recommendations
- [ ] Image analysis for food recognition

## API Reference

### ChatService

#### Methods

##### `sendMessage(String message, List<ChatMessage> conversationHistory)`
Mengirim pesan ke Gemini API dengan conversation history.

**Parameters**:
- `message`: Pesan dari user
- `conversationHistory`: Riwayat percakapan sebelumnya

**Returns**: `Future<String>` - Respons dari AI

**Throws**: `ChatException` - Jika terjadi error

##### `getErrorMessage(ChatException error)`
Static method untuk mendapatkan user-friendly error message.

**Parameters**:
- `error`: ChatException yang terjadi

**Returns**: `String` - Pesan error yang user-friendly

##### `getDisclaimerMessage()`
Static method untuk mendapatkan disclaimer message.

**Returns**: `String` - Disclaimer message

### ChatProvider

#### Properties

- `messages`: List<ChatMessage> - Daftar pesan (read-only)
- `isLoading`: bool - Status loading
- `errorMessage`: String? - Pesan error terakhir
- `isInitialized`: bool - Status inisialisasi
- `hasMessages`: bool - Apakah ada pesan

#### Methods

##### `initializeChat()`
Initialize chat dengan disclaimer message.

##### `sendMessage(String message)`
Mengirim pesan ke AI.

##### `clearConversation()`
Menghapus semua pesan dan reset state.

##### `restartConversation()`
Restart percakapan dengan disclaimer baru.

##### `clearError()`
Menghapus error message.

##### `getConversationSummary()`
Mendapatkan summary percakapan untuk debugging.

## Support

Untuk pertanyaan atau issues:
1. Check dokumentasi ini terlebih dahulu
2. Review test files untuk contoh usage
3. Check error messages untuk troubleshooting hints
4. Consult Gemini API documentation: https://ai.google.dev/docs

## License

Part of NutriBunda application. See main LICENSE file.
