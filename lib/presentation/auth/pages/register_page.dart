import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/input_validation/validate_email.dart';
import '../../../core/input_validation/validate_field.dart';
import '../../../core/input_validation/validate_password.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../bloc/register_bloc/register_bloc.dart';
import '../widgets/auth_text_field.dart';

/// Screen 05 — "أنشئ حسابك".
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate() && _agreed) {
      context.read<RegisterBloc>().add(
        RegisterSubmitted(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
    } else if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الموافقة على الشروط أولًا')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status == UIStatus.success) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
            } else if (state.status == UIStatus.error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
                    SizedBox(height: AppDimens.xl.h),
                    Text(
                      AppStrings.registerTitle,
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: AppDimens.xs.h),
                    Text(
                      AppStrings.registerSubtitle,
                      style: AppTextStyles.pageSubtitle,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: AppDimens.lg.h),
                    AuthTextField(
                      label: AppStrings.fullName,
                      controller: _name,
                      validator: (v) => validateField(
                        v ?? '',
                        context,
                        fieldName: AppStrings.fullName,
                      ),
                    ),
                    SizedBox(height: AppDimens.md.h),
                    AuthTextField(
                      label: AppStrings.email,
                      controller: _email,
                      hint: AppStrings.emailHint,
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
                    SizedBox(height: AppDimens.sm.h),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            AppStrings.agreeTerms,
                            textAlign: TextAlign.start,
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimens.md.h),
                    PrimaryButton(
                      label: AppStrings.createAccount,
                      loading: state.status == UIStatus.loading,
                      onPressed: () => _submit(context),
                    ),
                    SizedBox(height: AppDimens.xl.h),
                    GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.login,
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            AppStrings.haveAccount,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.md.h),
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
