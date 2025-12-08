import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';

// Animated Blob Widget for Lava Lamp Effect
class AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final Offset initialPosition;

  const AnimatedBlob({
    super.key,
    required this.color,
    required this.size,
    required this.duration,
    required this.initialPosition,
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: widget.initialPosition,
      end: Offset(
        widget.initialPosition.dx + 20,
        widget.initialPosition.dy - 20,
      ),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.4),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WelcomeScreen extends ConsumerStatefulWidget {
  final String? initialMode; // 'login' or 'register'
  
  const WelcomeScreen({super.key, this.initialMode});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  bool _showAuthSheet = false;
  bool _isLoginMode = true;

  // Controllers for login form
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _isLoggingIn = false;

  // Controllers for register form
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isRegistering = false;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeAnimation;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );

    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _welcomeAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut),
    );
    
    // Check if we should auto-open auth sheet based on initialMode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialMode();
    });
  }
  
  void _checkInitialMode() {
    // Get mode from query parameter
    final uri = GoRouterState.of(context).uri;
    final mode = uri.queryParameters['mode'] ?? widget.initialMode;
    
    if (mode != null) {
      setState(() {
        _isLoginMode = mode != 'register';
      });
      _openAuthSheet();
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _welcomeController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _openAuthSheet() {
    setState(() => _showAuthSheet = true);
    _sheetController.forward();
    _welcomeController.forward();
  }

  void _closeAuthSheet() {
    _sheetController.reverse().then((_) {
      setState(() => _showAuthSheet = false);
    });
    _welcomeController.reverse();
  }

  void _switchToLogin() {
    setState(() => _isLoginMode = true);
  }

  void _switchToRegister() {
    setState(() => _isLoginMode = false);
  }

  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate() && !_isLoggingIn) {
      setState(() => _isLoggingIn = true);

      try {
        final notifier = ref.read(authStateProvider.notifier);

        await notifier.login(
          _loginEmailController.text.trim(),
          _loginPasswordController.text,
        );

        if (!mounted) return;

        final authState = ref.read(authStateProvider);
        if (authState.valueOrNull?.isLoggedIn == true) {
          if (mounted) {
            context.go('/main');
          }
        } else if (authState.valueOrNull?.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.value!.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingIn = false);
        }
      }
    }
  }

  Future<void> _register() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_registerFormKey.currentState!.validate() && !_isRegistering) {
      setState(() => _isRegistering = true);

      try {
        await ref.read(authStateProvider.notifier).register(
              _registerNameController.text.trim(),
              _registerEmailController.text.trim(),
              _registerPasswordController.text,
              _registerConfirmPasswordController.text,
            );

        if (!mounted) return;

        final authState = ref.read(authStateProvider);
        if (authState.valueOrNull?.isLoggedIn == true) {
          if (mounted) context.go('/main');
        } else if (authState.valueOrNull?.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.value!.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isRegistering = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF16213e),
      body: Stack(
        children: [
          // Animated Blobs (Lava Lamp Effect)
          AnimatedBlob(
            color: const Color(0xFFFF007A),
            size: 300,
            duration: const Duration(seconds: 10),
            initialPosition: Offset(-size.width * 0.15, -size.height * 0.1),
          ),
          AnimatedBlob(
            color: const Color(0xFF7A00FF),
            size: 250,
            duration: const Duration(seconds: 12),
            initialPosition: Offset(size.width * 0.6, size.height * 0.7),
          ),
          AnimatedBlob(
            color: const Color(0xFF00D2FF),
            size: 150,
            duration: const Duration(seconds: 15),
            initialPosition: Offset(size.width * 0.2, size.height * 0.4),
          ),

          // Welcome Screen Content
          AnimatedBuilder(
            animation: _welcomeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _welcomeAnimation.value,
                child: Opacity(
                  opacity: _showAuthSheet ? 0.5 : 1.0,
                  child: child,
                ),
              );
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    // Welcome Header
                    const Text(
                      'SportLife',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black38,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Dự đoán tỉ số, nhận quà cực chất!\nTham gia cộng đồng bóng đá sôi động nhất.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Start Button
                    GestureDetector(
                      onTap: _openAuthSheet,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bắt đầu ngay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF16213e),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Auth Bottom Sheet
          if (_showAuthSheet)
            AnimatedBuilder(
              animation: _sheetAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: size.height * 0.85 * _sheetAnimation.value,
                  child: child!,
                );
              },
              child: _buildAuthSheet(size),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthSheet(Size size) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D).withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Drag Handle
              GestureDetector(
                onTap: _closeAuthSheet,
                child: Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Toggle Box (Login / Signup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: _buildToggleBox(),
              ),
              const SizedBox(height: 20),
              // Forms
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: _isLoginMode
                          ? const Offset(-1.0, 0.0)
                          : const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ));
                    return SlideTransition(
                      position: slideAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _isLoginMode
                      ? _buildLoginForm(key: const ValueKey('login'))
                      : _buildRegisterForm(key: const ValueKey('register')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleBox() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Animated Indicator
          AnimatedAlign(
            alignment:
                _isLoginMode ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: Container(
              width: (MediaQuery.of(context).size.width - 70) / 2,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _switchToLogin,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: _isLoginMode ? Colors.white : Colors.grey,
                        fontWeight:
                            _isLoginMode ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _switchToRegister,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: !_isLoginMode ? Colors.white : Colors.grey,
                        fontWeight:
                            !_isLoginMode ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Email Input
            _buildInputField(
              controller: _loginEmailController,
              hint: 'Email của bạn',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password Input
            _buildInputField(
              controller: _loginPasswordController,
              hint: 'Mật khẩu',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureLoginPassword,
              onToggleObscure: () {
                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
            ),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Login Button
            _buildSubmitButton(
              text: 'Đăng Nhập',
              isLoading: _isLoggingIn,
              onPressed: _login,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 30),
            // Social Login
            _buildSocialLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Name Input
            _buildInputField(
              controller: _registerNameController,
              hint: 'Tên hiển thị',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Email Input
            _buildInputField(
              controller: _registerEmailController,
              hint: 'Email đăng ký',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password Input
            _buildInputField(
              controller: _registerPasswordController,
              hint: 'Tạo mật khẩu',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureRegisterPassword,
              onToggleObscure: () {
                setState(
                    () => _obscureRegisterPassword = !_obscureRegisterPassword);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 8) {
                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Confirm Password Input
            _buildInputField(
              controller: _registerConfirmPasswordController,
              hint: 'Xác nhận mật khẩu',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _registerPasswordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Terms Checkbox
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _agreeToTerms = !_agreeToTerms);
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _agreeToTerms
                          ? const Color(0xFFFF007A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _agreeToTerms
                            ? const Color(0xFFFF007A)
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: _agreeToTerms
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _agreeToTerms = !_agreeToTerms);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                        children: const [
                          TextSpan(text: 'Tôi đồng ý với '),
                          TextSpan(
                            text: 'Điều khoản',
                            style: TextStyle(
                              color: Color(0xFFFF007A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Chính sách',
                            style: TextStyle(
                              color: Color(0xFFFF007A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Register Button
            _buildSubmitButton(
              text: 'Tạo Tài Khoản',
              isLoading: _isRegistering,
              onPressed: _register,
              color: const Color(0xFFFF007A),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Text(
          'Hoặc tiếp tục với',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata_rounded, 'Google'),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.facebook_rounded, 'Facebook'),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.apple_rounded, 'Apple'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement social login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập với $label sẽ sớm có!')),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

