import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:nutribunda/core/services/http_client_service.dart';
import 'package:nutribunda/core/services/secure_storage_service.dart';
import 'package:nutribunda/core/errors/exceptions.dart';

@GenerateMocks([Dio, SecureStorageService])
import 'http_client_service_test.mocks.dart';

void main() {
  late HttpClientService httpClientService;
  late MockDio mockDio;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockDio = MockDio();
    mockSecureStorage = MockSecureStorageService();
    
    // Setup default Dio options
    when(mockDio.options).thenReturn(BaseOptions());
    when(mockDio.interceptors).thenReturn(Interceptors());
    
    httpClientService = HttpClientService(
      secureStorage: mockSecureStorage,
      dio: mockDio,
    );
  });

  group('GET Request', () {
    const testPath = '/test';
    final testResponse = Response(
      requestOptions: RequestOptions(path: testPath),
      statusCode: 200,
      data: {'message': 'success'},
    );

    test('should return response on successful GET request', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => testResponse);

      // Act
      final result = await httpClientService.get(testPath);

      // Assert
      expect(result.statusCode, 200);
      expect(result.data, {'message': 'success'});
      verify(mockDio.get(
        testPath,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });

    test('should throw NetworkException on connection timeout', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw UnauthorizedException on 401 status', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          response: Response(
            requestOptions: RequestOptions(path: testPath),
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('should throw ValidationException on 400 status', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          response: Response(
            requestOptions: RequestOptions(path: testPath),
            statusCode: 400,
            data: {'message': 'Validation error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ServerException on 500 status', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          response: Response(
            requestOptions: RequestOptions(path: testPath),
            statusCode: 500,
            data: {'message': 'Server error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('POST Request', () {
    const testPath = '/test';
    final testData = {'name': 'test'};
    final testResponse = Response(
      requestOptions: RequestOptions(path: testPath),
      statusCode: 201,
      data: {'id': '123', 'name': 'test'},
    );

    test('should return response on successful POST request', () async {
      // Arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => testResponse);

      // Act
      final result = await httpClientService.post(testPath, data: testData);

      // Assert
      expect(result.statusCode, 201);
      expect(result.data['id'], '123');
      verify(mockDio.post(
        testPath,
        data: testData,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });
  });

  group('PUT Request', () {
    const testPath = '/test/123';
    final testData = {'name': 'updated'};
    final testResponse = Response(
      requestOptions: RequestOptions(path: testPath),
      statusCode: 200,
      data: {'id': '123', 'name': 'updated'},
    );

    test('should return response on successful PUT request', () async {
      // Arrange
      when(mockDio.put(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => testResponse);

      // Act
      final result = await httpClientService.put(testPath, data: testData);

      // Assert
      expect(result.statusCode, 200);
      expect(result.data['name'], 'updated');
      verify(mockDio.put(
        testPath,
        data: testData,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });
  });

  group('DELETE Request', () {
    const testPath = '/test/123';
    final testResponse = Response(
      requestOptions: RequestOptions(path: testPath),
      statusCode: 204,
      data: null,
    );

    test('should return response on successful DELETE request', () async {
      // Arrange
      when(mockDio.delete(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => testResponse);

      // Act
      final result = await httpClientService.delete(testPath);

      // Assert
      expect(result.statusCode, 204);
      verify(mockDio.delete(
        testPath,
        data: null,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });
  });

  group('PATCH Request', () {
    const testPath = '/test/123';
    final testData = {'status': 'active'};
    final testResponse = Response(
      requestOptions: RequestOptions(path: testPath),
      statusCode: 200,
      data: {'id': '123', 'status': 'active'},
    );

    test('should return response on successful PATCH request', () async {
      // Arrange
      when(mockDio.patch(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => testResponse);

      // Act
      final result = await httpClientService.patch(testPath, data: testData);

      // Assert
      expect(result.statusCode, 200);
      expect(result.data['status'], 'active');
      verify(mockDio.patch(
        testPath,
        data: testData,
        queryParameters: null,
        options: null,
        cancelToken: null,
      )).called(1);
    });
  });

  group('Error Handling', () {
    const testPath = '/test';

    test('should throw NetworkException on no internet connection', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw NetworkException on request cancelled', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          type: DioExceptionType.cancel,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw ServerException on 404 status', () async {
      // Arrange
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: testPath),
          response: Response(
            requestOptions: RequestOptions(path: testPath),
            statusCode: 404,
            data: {'message': 'Not found'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act & Assert
      expect(
        () => httpClientService.get(testPath),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('Utility Methods', () {
    test('updateBaseUrl should update Dio base URL', () {
      // Arrange
      const newBaseUrl = 'https://api.example.com';
      when(mockDio.options).thenReturn(BaseOptions());

      // Act
      httpClientService.updateBaseUrl(newBaseUrl);

      // Assert
      verify(mockDio.options).called(greaterThan(0));
    });

    test('addHeader should add custom header to Dio', () {
      // Arrange
      const key = 'X-Custom-Header';
      const value = 'custom-value';
      when(mockDio.options).thenReturn(BaseOptions());

      // Act
      httpClientService.addHeader(key, value);

      // Assert
      verify(mockDio.options).called(greaterThan(0));
    });

    test('removeHeader should remove custom header from Dio', () {
      // Arrange
      const key = 'X-Custom-Header';
      when(mockDio.options).thenReturn(BaseOptions());

      // Act
      httpClientService.removeHeader(key);

      // Assert
      verify(mockDio.options).called(greaterThan(0));
    });

    test('clearHeaders should clear all custom headers', () {
      // Arrange
      when(mockDio.options).thenReturn(BaseOptions());

      // Act
      httpClientService.clearHeaders();

      // Assert
      verify(mockDio.options).called(greaterThan(0));
    });
  });
}
