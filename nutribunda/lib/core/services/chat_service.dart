import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../../data/models/chat_message.dart';

/// Service untuk mengelola integrasi dengan Gemini API
/// Requirements: 9.1, 9.2, 9.3, 9.4 - TanyaBunda AI chatbot functionality
/// 
/// Fitur:
/// - Mengirim pertanyaan ke Gemini API dengan system prompt
/// - Mengelola conversation history
/// - Error handling untuk network failures, timeouts, dan API errors
/// - Membatasi topik pada domain gizi MPASI dan diet ibu
class ChatService {
  final Dio _dio;
  
  // System prompt untuk membatasi topik percakapan
  // Requirements: 9.3 - Membatasi topik pada domain gizi MPASI
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

  /// ChatService selalu membuat Dio-nya sendiri agar tidak
  /// menimpa konfigurasi Dio backend yang digunakan HttpClientService.
  ChatService({Dio? dio}) : _dio = dio ?? Dio() {
    // Selalu konfigurasi ulang agar baseUrl mengarah ke Gemini
    _configureDio();
  }

  /// Konfigurasi Dio untuk Gemini API
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.geminiBaseUrl,
      // Diperpanjang ke 30 detik agar tidak premature timeout
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  /// Mengirim pesan ke Gemini API dengan conversation history
  /// Requirements: 9.2 - Mengirim pertanyaan dan menampilkan respons < 10 detik
  /// 
  /// [message] - Pesan dari user
  /// [conversationHistory] - Riwayat percakapan sebelumnya
  /// 
  /// Returns: Respons dari AI
  /// Throws: [ChatException] jika terjadi error
  Future<String> sendMessage(
    String message,
    List<ChatMessage> conversationHistory,
  ) async {
    try {
      // Build conversation contents dengan system prompt
      final contents = _buildConversationContents(message, conversationHistory);

      // Kirim request ke Gemini API
      final response = await _dio.post(
        '/models/${ApiConstants.geminiModel}:generateContent',
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
      );

      // Parse response
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      // Check for API key validation error
      if (e is ChatException) rethrow;
      
      throw ChatException(
        'Terjadi kesalahan yang tidak terduga: ${e.toString()}',
        ChatErrorType.unknown,
      );
    }
  }

  /// Build conversation contents untuk Gemini API
  /// Menggabungkan system prompt dengan conversation history
  List<Map<String, dynamic>> _buildConversationContents(
    String currentMessage,
    List<ChatMessage> history,
  ) {
    final contents = <Map<String, dynamic>>[];

    // Tambahkan system prompt sebagai pesan pertama dari user
    contents.add({
      'role': 'user',
      'parts': [
        {'text': systemPrompt}
      ],
    });

    // Tambahkan acknowledgment dari model
    contents.add({
      'role': 'model',
      'parts': [
        {'text': 'Baik, saya siap membantu Anda dengan pertanyaan seputar gizi MPASI dan diet ibu pasca-melahirkan.'}
      ],
    });

    // Tambahkan conversation history (maksimal 10 pesan terakhir untuk efisiensi)
    final recentHistory = history.length > 10 
        ? history.sublist(history.length - 10) 
        : history;
    
    for (final msg in recentHistory) {
      contents.add(msg.toGeminiFormat());
    }

    // Tambahkan pesan saat ini
    contents.add({
      'role': 'user',
      'parts': [
        {'text': currentMessage}
      ],
    });

    return contents;
  }

  /// Parse response dari Gemini API
  /// Requirements: 9.2 - Menampilkan respons dalam waktu < 10 detik
  String _parseResponse(Response response) {
    try {
      if (response.statusCode != 200) {
        throw ChatException(
          'API mengembalikan status code ${response.statusCode}',
          ChatErrorType.invalidResponse,
        );
      }

      final data = response.data as Map<String, dynamic>;
      
      // Check for blocked content
      if (data.containsKey('promptFeedback')) {
        final feedback = data['promptFeedback'] as Map<String, dynamic>;
        if (feedback.containsKey('blockReason')) {
          throw ChatException(
            'Maaf, pertanyaan Anda tidak dapat diproses karena melanggar kebijakan konten.',
            ChatErrorType.invalidResponse,
          );
        }
      }

      // Extract response text
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw ChatException(
          'API tidak mengembalikan respons yang valid',
          ChatErrorType.invalidResponse,
        );
      }

      final firstCandidate = candidates[0] as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw ChatException(
          'Format respons API tidak valid',
          ChatErrorType.invalidResponse,
        );
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw ChatException(
          'Respons API tidak mengandung teks',
          ChatErrorType.invalidResponse,
        );
      }

      final text = (parts[0] as Map<String, dynamic>)['text'] as String?;
      if (text == null || text.isEmpty) {
        throw ChatException(
          'Respons API kosong',
          ChatErrorType.invalidResponse,
        );
      }

      return text;
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException(
        'Gagal memproses respons dari API: ${e.toString()}',
        ChatErrorType.invalidResponse,
      );
    }
  }

  /// Handle Dio errors dan convert ke ChatException
  /// Requirements: 9.4 - Error handling untuk API failures
  ChatException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Requirements: 9.4 - Menampilkan pesan kesalahan informatif
        return ChatException(
          'Koneksi timeout. Gemini API tidak merespons dalam waktu yang ditentukan. Silakan coba lagi.',
          ChatErrorType.apiTimeout,
        );

      case DioExceptionType.connectionError:
        return ChatException(
          'Tidak dapat terhubung ke Gemini API. Silakan periksa koneksi internet Anda.',
          ChatErrorType.networkError,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorData = error.response?.data;

        if (statusCode == 429) {
          return ChatException(
            'Terlalu banyak permintaan. Silakan tunggu beberapa saat sebelum mencoba lagi.',
            ChatErrorType.rateLimitExceeded,
          );
        } else if (statusCode == 400) {
          // Parse error message from API
          String message = 'Permintaan tidak valid.';
          if (errorData is Map && errorData.containsKey('error')) {
            final errorInfo = errorData['error'] as Map<String, dynamic>;
            message = errorInfo['message'] as String? ?? message;
          }
          return ChatException(message, ChatErrorType.invalidResponse);
        } else if (statusCode == 401 || statusCode == 403) {
          return ChatException(
            'API key tidak valid atau tidak memiliki akses. Silakan hubungi administrator.',
            ChatErrorType.apiKeyInvalid,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ChatException(
            'Server Gemini API mengalami masalah. Silakan coba lagi nanti.',
            ChatErrorType.networkError,
          );
        }
        return ChatException(
          'Terjadi kesalahan saat berkomunikasi dengan Gemini API (${statusCode ?? 'unknown'}).',
          ChatErrorType.unknown,
        );

      case DioExceptionType.cancel:
        return ChatException(
          'Permintaan dibatalkan.',
          ChatErrorType.unknown,
        );

      case DioExceptionType.badCertificate:
        return ChatException(
          'Kesalahan sertifikat SSL. Silakan periksa koneksi internet Anda.',
          ChatErrorType.networkError,
        );

      case DioExceptionType.unknown:
        return ChatException(
          'Tidak dapat terhubung ke Gemini API. Silakan periksa koneksi internet Anda.',
          ChatErrorType.networkError,
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
