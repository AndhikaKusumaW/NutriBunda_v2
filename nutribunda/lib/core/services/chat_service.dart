import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'dart:io';

/// Service untuk mengelola integrasi dengan Gemini API
/// Requirements: 9.1, 9.2, 9.3, 9.4 - TanyaBunda AI chatbot functionality
/// 
/// Fitur:
/// - Mengelola percakapan menggunakan google_generative_ai
/// - Mengelola ChatSession untuk conversation history
/// - Membatasi topik pada domain gizi MPASI dan diet ibu
class ChatService {
  ChatSession? _chatSession;

  // System prompt untuk membatasi topik percakapan
  static const String systemPrompt = '''
Anda adalah TanyaBunda AI, asisten konsultan gizi MPASI dan diet ibu pasca-melahirkan yang ramah dan profesional.

FOKUS TOPIK:
- Gizi MPASI untuk bayi usia 6-24 bulan
- Resep dan menu MPASI yang sehat dan bergizi
- Jadwal pemberian makan bayi
- Diet pemulihan ibu pasca-melahirkan
- Nutrisi untuk ibu menyusui
- Validasi mitos dan fakta seputar nutrisi bayi dan ibu

PANDUAN MENJAWAB:
- Jawab dalam Bahasa Indonesia yang mudah dipahami
- Berikan informasi yang akurat dan berbasis ilmiah
- Jika pertanyaan di luar topik, arahkan kembali ke topik gizi MPASI dan diet ibu
- Jika pertanyaan memerlukan diagnosis medis, sarankan konsultasi dengan dokter atau ahli gizi
- Berikan contoh praktis dan tips yang mudah diterapkan
- Gunakan nada yang hangat, mendukung, dan tidak menghakimi

DISCLAIMER:
Selalu ingatkan bahwa informasi yang diberikan bersifat edukatif dan bukan pengganti konsultasi medis profesional.
''';

  ChatService() {
    // Session is initialized lazily or explicitly via startNewSession
    startNewSession();
  }

  /// Memulai sesi percakapan baru dengan Gemini
  void startNewSession() {
    final model = GenerativeModel(
      model: ApiConstants.geminiModel,
      apiKey: ApiConstants.geminiApiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );

    // Initial history with acknowledgment to set the tone
    _chatSession = model.startChat(history: [
      Content.model([
        TextPart('Baik, saya siap membantu Anda dengan pertanyaan seputar gizi MPASI dan diet ibu pasca-melahirkan.')
      ])
    ]);
  }

  /// Mengirim pesan ke Gemini API
  /// Requirements: 9.2 - Mengirim pertanyaan dan menampilkan respons < 10 detik
  /// 
  /// [message] - Pesan dari user
  /// 
  /// Returns: Respons dari AI
  /// Throws: [ChatException] jika terjadi error
  Future<String> sendMessage(String message) async {
    try {
      if (_chatSession == null) {
        startNewSession();
      }

      final response = await _chatSession!
      .sendMessage(
        Content.text(message))
      .timeout(ApiConstants.geminiTimeout, onTimeout: () {
          throw ChatException('Request timeout', ChatErrorType.apiTimeout);
      });

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw ChatException(
          'API tidak mengembalikan respons yang valid',
          ChatErrorType.invalidResponse,
        );
      }
      return text;
    } on TimeoutException {
      throw ChatException('Timeout', ChatErrorType.apiTimeout);
    } on SocketException {
      throw ChatException('No Internet', ChatErrorType.networkError);
    } on GenerativeAIException catch (e) {
      throw ChatException(
        'Gagal memproses pesan: ${e.message}',
        ChatErrorType.invalidResponse,
      );
    } catch (e) {
      if (e is ChatException) rethrow;
      
      throw ChatException(
        'Terjadi kesalahan yang tidak terduga: ${e.toString()}',
        ChatErrorType.unknown,
      );
    }
  }

  /// Get user-friendly error message berdasarkan error type
  /// Requirements: 9.4 - Menampilkan pesan kesalahan yang informatif
  static String getErrorMessage(ChatException error) {
    switch (error.type) {
      case ChatErrorType.networkError:
        return 'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda dan coba lagi.';
      case ChatErrorType.apiTimeout:
        return 'Permintaan memakan waktu terlalu lama. Silakan coba lagi.';
      case ChatErrorType.invalidResponse:
        return error.message;
      case ChatErrorType.rateLimitExceeded:
        return 'Terlalu banyak permintaan. Silakan tunggu beberapa saat sebelum mencoba lagi.';
      case ChatErrorType.apiKeyInvalid:
        return 'Konfigurasi API tidak valid. Silakan hubungi administrator aplikasi.';
      case ChatErrorType.unknown:
        return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
    }
  }

  /// Get disclaimer message untuk ditampilkan di awal percakapan
  /// Requirements: 9.5 - Menampilkan peringatan bahwa respons AI bukan pengganti konsultasi medis
  static String getDisclaimerMessage() {
    return '''
⚠️ DISCLAIMER

Informasi yang diberikan oleh TanyaBunda AI bersifat edukatif dan tidak menggantikan konsultasi medis profesional.

Untuk diagnosis, pengobatan, atau kondisi kesehatan yang serius, selalu konsultasikan dengan dokter, ahli gizi, atau tenaga kesehatan profesional.

TanyaBunda AI siap membantu Anda dengan informasi seputar:
• Gizi MPASI untuk bayi 6-24 bulan
• Resep dan menu MPASI
• Diet pemulihan ibu pasca-melahirkan
• Nutrisi untuk ibu menyusui
• Validasi mitos dan fakta nutrisi

Silakan ajukan pertanyaan Anda! 😊
''';
  }
}
