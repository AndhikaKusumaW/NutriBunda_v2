# Gemini API Setup Guide - TanyaBunda AI

## Quick Start

This guide will help you set up the Gemini API integration for the TanyaBunda AI chatbot feature.

## Prerequisites

- Flutter project set up and running
- Internet connection
- Google account

## Step 1: Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key
5. **IMPORTANT**: Save this key securely - you won't be able to see it again!

## Step 2: Configure API Key

### Option A: Development (Quick Setup)

1. Open `nutribunda/lib/core/constants/api_constants.dart`
2. Find the line:
   ```dart
   static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
3. Replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String geminiApiKey = 'AIzaSyD...your-actual-key...';
   ```

**⚠️ WARNING**: Never commit this file with your actual API key to version control!

### Option B: Production (Recommended)

1. Create a `.env` file in the project root (if not exists):
   ```bash
   touch .env
   ```

2. Add your API key to `.env`:
   ```
   GEMINI_API_KEY=AIzaSyD...your-actual-key...
   ```

3. Add `.env` to `.gitignore`:
   ```
   .env
   ```

4. Update `api_constants.dart` to read from environment:
   ```dart
   static final String geminiApiKey = 
       const String.fromEnvironment('GEMINI_API_KEY', 
           defaultValue: 'YOUR_GEMINI_API_KEY_HERE');
   ```

5. Run with environment variable:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your-actual-key
   ```

## Step 3: Verify Setup

### Test with Unit Tests

```bash
cd nutribunda
flutter test test/core/services/chat_service_test.dart
```

Expected output:
```
✅ All tests passed!
```

### Test with Manual Integration

Create a simple test file `test_gemini.dart`:

```dart
import 'package:nutribunda/core/services/chat_service.dart';
import 'package:nutribunda/data/models/chat_message.dart';

void main() async {
  final chatService = ChatService();
  
  try {
    print('Testing Gemini API...');
    final response = await chatService.sendMessage(
      'Apa itu MPASI?',
      [],
    );
    print('✅ Success! Response: $response');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

Run:
```bash
dart test_gemini.dart
```

## Step 4: Register Provider

Add ChatProvider to your app's provider setup:

```dart
// In main.dart or injection_container.dart
import 'package:nutribunda/presentation/providers/chat_provider.dart';
import 'package:nutribunda/core/services/chat_service.dart';

MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(
      create: (_) => ChatProvider(
        chatService: ChatService(),
      ),
    ),
  ],
  child: MyApp(),
)
```

## Step 5: Use in Your App

### Initialize Chat

```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initializeChat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TanyaBunda AI')),
      body: ChatWidget(),
    );
  }
}
```

### Display Messages

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    if (chatProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return ListTile(
          title: Text(message.content),
          subtitle: Text(message.isUser ? 'You' : 'AI'),
        );
      },
    );
  },
)
```

### Send Messages

```dart
final _controller = TextEditingController();

TextField(
  controller: _controller,
  decoration: InputDecoration(
    hintText: 'Tanya seputar MPASI...',
    suffixIcon: IconButton(
      icon: Icon(Icons.send),
      onPressed: () {
        final text = _controller.text.trim();
        if (text.isNotEmpty) {
          context.read<ChatProvider>().sendMessage(text);
          _controller.clear();
        }
      },
    ),
  ),
)
```

## Troubleshooting

### Issue: "API key belum dikonfigurasi"

**Solution**: 
- Check that you've replaced `YOUR_GEMINI_API_KEY_HERE` with your actual key
- Verify the key is correct (no extra spaces or quotes)
- Restart the app after changing the key

### Issue: "Tidak dapat terhubung ke Gemini API"

**Possible Causes**:
- No internet connection
- Firewall blocking the request
- API key is invalid

**Solutions**:
1. Check internet connection
2. Verify API key is correct
3. Check if you can access https://generativelanguage.googleapis.com in browser
4. Try regenerating API key in Google AI Studio

### Issue: "Terlalu banyak permintaan"

**Cause**: Rate limit exceeded (free tier has limits)

**Solutions**:
- Wait a few minutes before trying again
- Consider upgrading to paid tier for higher limits
- Implement request throttling in your app

### Issue: Tests failing

**Solutions**:
1. Run `flutter pub get` to ensure dependencies are installed
2. Run `flutter pub run build_runner build` to generate mocks
3. Check that all files are saved
4. Restart IDE/editor

## API Limits (Free Tier)

- **Requests per minute**: 60
- **Requests per day**: 1,500
- **Tokens per minute**: 32,000

For production use, consider:
- Implementing request caching
- Adding rate limiting
- Upgrading to paid tier if needed

## Security Best Practices

1. **Never commit API keys**
   ```bash
   # Add to .gitignore
   .env
   **/api_constants.dart  # If you hardcode keys
   ```

2. **Use environment variables in production**
   ```dart
   const String.fromEnvironment('GEMINI_API_KEY')
   ```

3. **Rotate keys regularly**
   - Generate new key every 3-6 months
   - Revoke old keys in Google AI Studio

4. **Monitor usage**
   - Check Google AI Studio dashboard
   - Set up usage alerts
   - Monitor for unusual activity

## Next Steps

1. ✅ API key configured
2. ✅ Tests passing
3. ✅ Provider registered
4. ⏭️ Build chat UI (Task 13.2)
5. ⏭️ Integration testing (Task 13.3)

## Resources

- [Gemini API Documentation](https://ai.google.dev/docs)
- [Google AI Studio](https://makersuite.google.com/)
- [Flutter Provider Documentation](https://pub.dev/packages/provider)
- [ChatService README](lib/core/services/CHAT_SERVICE_README.md)

## Support

If you encounter issues:
1. Check this guide first
2. Review error messages carefully
3. Check the ChatService README for detailed documentation
4. Review test files for usage examples

## Example .env File

```env
# Gemini API Configuration
GEMINI_API_KEY=AIzaSyD...your-actual-key...

# Other environment variables
# API_BASE_URL=http://localhost:8080
```

## Example .gitignore Entry

```gitignore
# Environment files
.env
.env.local
.env.*.local

# API keys (if hardcoded for development)
# lib/core/constants/api_constants.dart
```

## Verification Checklist

Before moving to Task 13.2, verify:

- [ ] Gemini API key obtained from Google AI Studio
- [ ] API key configured in `api_constants.dart`
- [ ] `.env` file created (if using environment variables)
- [ ] `.gitignore` updated to exclude sensitive files
- [ ] Unit tests passing (`flutter test`)
- [ ] ChatProvider registered in app
- [ ] Manual test successful (can send/receive messages)
- [ ] Error handling works (test with invalid key)
- [ ] Disclaimer message displays correctly

## Ready to Go!

Once all checklist items are complete, you're ready to:
- Build the chat UI (Task 13.2)
- Test the complete feature
- Deploy to production

Happy coding! 🚀
