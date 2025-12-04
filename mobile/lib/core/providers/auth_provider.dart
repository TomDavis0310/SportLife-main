import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/models/user.dart';
import '../../features/auth/data/api/auth_api.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

// Auth API Provider
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthApi authApi;

  AuthNotifier(this.authApi) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final isLoggedIn = await SecureStorage.isLoggedIn();
      if (isLoggedIn) {
        final user = await authApi.getProfile();
        state = AsyncValue.data(AuthState(user: user));
      } else {
        state = const AsyncValue.data(AuthState());
      }
    } catch (e) {
      state = const AsyncValue.data(AuthState());
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    try {
      final response = await authApi.login(email: email, password: password);
      await SecureStorage.saveToken(response.token);
      state = AsyncValue.data(AuthState(user: response.user));
    } catch (e) {
      // If it's a Dio error, try to extract a readable message from the response
      if (e is DioException) {
        final data = e.response?.data;
        // Log raw response for debugging
        // ignore: avoid_print
        print('Auth login error response: $data');
        String msg = e.toString();
        if (data != null) {
          if (data is Map && data['errors'] != null) {
            try {
              msg = (data['errors'] as Map).values
                  .expand((v) => (v as List).map((i) => i.toString()))
                  .join(', ');
            } catch (_) {
              msg = data.toString();
            }
          } else if (data['message'] != null) {
            msg = data['message'].toString();
          } else {
            msg = data.toString();
          }
        }
        state = AsyncValue.data(AuthState(error: msg));
      } else {
        state = AsyncValue.data(AuthState(error: e.toString()));
      }
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    try {
      final response = await authApi.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await SecureStorage.saveToken(response.token);
      state = AsyncValue.data(AuthState(user: response.user));
    } catch (e) {
      // Extract readable server validation messages for Dio errors
      if (e is DioException) {
        final data = e.response?.data;
        // ignore: avoid_print
        print('Auth register error response: $data');
        String msg = e.toString();
        if (data != null) {
          if (data is Map && data['errors'] != null) {
            try {
              msg = (data['errors'] as Map).values
                  .expand((v) => (v as List).map((i) => i.toString()))
                  .join(', ');
            } catch (_) {
              msg = data.toString();
            }
          } else if (data['message'] != null) {
            msg = data['message'].toString();
          } else {
            msg = data.toString();
          }
        }
        state = AsyncValue.data(AuthState(error: msg));
      } else {
        state = AsyncValue.data(AuthState(error: e.toString()));
      }
    }
  }

  Future<void> socialLogin(String provider, String token) async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    try {
      final response = await authApi.socialLogin(
        provider: provider,
        token: token,
      );
      await SecureStorage.saveToken(response.token);
      state = AsyncValue.data(AuthState(user: response.user));
    } catch (e) {
      state = AsyncValue.data(AuthState(error: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authApi.logout();
    } finally {
      await SecureStorage.clearAll();
      state = const AsyncValue.data(AuthState());
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await authApi.getProfile();
      state = AsyncValue.data(AuthState(user: user));
    } catch (e) {
      // Keep current state
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    int? favoriteTeamId,
  }) async {
    try {
      final user = await authApi.updateProfile(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        favoriteTeamId: favoriteTeamId,
      );
      state = AsyncValue.data(AuthState(user: user));
    } catch (e) {
      final currentState = state.value ?? const AuthState();
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
    }
  }
}

// Auth State Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref.watch(authApiProvider));
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user;
});

// Is Logged In Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.isLoggedIn ?? false;
});

// Alias for authStateProvider for backward compatibility
final authNotifierProvider = authStateProvider;

