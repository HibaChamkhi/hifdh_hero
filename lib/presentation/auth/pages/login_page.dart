import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/input_validation/validate_email.dart';
import '../../../core/input_validation/validate_password.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/page_header.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../bloc/login_bloc/login_bloc.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_text_field.dart';

/// Screen 04 — "مرحبًا بعودتك".
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
            LoginSubmitted(email: _email.text.trim(), password: _password.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == UIStatus.success) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home, (r) => false);
            } else if (state.status == UIStatus.error) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppDimens.lg.h),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AuthLogo(),
                    ),
                    SizedBox(height: AppDimens.xl.h),
                    const PageHeader(
                      title: AppStrings.welcomeBack,
                      subtitle: AppStrings.welcomeBackSubtitle,
                    ),
                    SizedBox(height: AppDimens.xl.h),
                    AuthTextField(
                      label: AppStrings.email,
                      controller: _email,
                      hint: 'sara@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => validateEmail(v ?? '', context),
                    ),
                    SizedBox(height: AppDimens.md.h),
                    AuthTextField(
                      label: AppStrings.password,
                      controller: _password,
                      obscure: true,
                      validator: (v) => validatePassword(v ?? '', context),
                    ),
                    SizedBox(height: AppDimens.md.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.forgotPassword),
                        child: Text(AppStrings.forgotPassword,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyStrong
                                .copyWith(color: AppColors.primary)),
                      ),
                    ),
                    SizedBox(height: AppDimens.md.h),
                    PrimaryButton(
                      label: AppStrings.login,
                      loading: state.status == UIStatus.loading,
                      onPressed: () => _submit(context),
                    ),
                    SizedBox(height: AppDimens.xxl.h),
                    _FooterLink(
                      leading: AppStrings.noAccount,
                      action: AppStrings.createAccount,
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.register),
                    ),
                    SizedBox(height: AppDimens.lg.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String leading;
  final String action;
  final VoidCallback onTap;
  const _FooterLink({
    required this.leading,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        // RTL: `start` puts the line against the right edge.
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(leading, style: AppTextStyles.caption),
          SizedBox(width: 4.w),
          Text(action,
              style: AppTextStyles.bodyStrong
                  .copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
