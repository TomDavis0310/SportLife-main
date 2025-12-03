import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<AuthResponse> socialLogin({
    required String provider,
    required String token,
  }) async {
    final response = await dio.post(
      '/auth/social/$provider',
      data: {'token': token},
    );
    return AuthResponse.fromJson(response.data['data']);
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }

  Future<User> getProfile() async {
    final response = await dio.get('/profile');
    return User.fromJson(response.data['data']);
  }

  Future<User> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    int? favoriteTeamId,
  }) async {
    final response = await dio.put(
      '/profile',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (favoriteTeamId != null) 'favorite_team_id': favoriteTeamId,
      },
    );
    return User.fromJson(response.data['data']);
  }

  Future<User> updateAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post('/profile/avatar', data: formData);
    return User.fromJson(response.data['data']);
  }

  Future<void> forgotPassword(String email) async {
    await dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await dio.put(
      '/profile/password',
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
  }
}

