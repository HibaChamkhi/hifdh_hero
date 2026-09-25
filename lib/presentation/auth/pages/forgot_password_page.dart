import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/input_validation/validate_email.dart';
import '../../../core/model/ui_state.dart';
import '../../../core/ui/styles/colors.dart';
import '../../../core/ui/styles/dimens.dart';
import '../../../core/ui/styles/text_styles.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../bloc/forgot_password_bloc/forgot_password_bloc.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_text_field.dart';

/// Screen 06 — "نسيت كلمة المرور؟".
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordBloc>(),
      child: const _ForgotView(),
    );
  }
}

class _ForgotView extends StatefulWidget {
  const _ForgotView();

  @override
  State<_ForgotView> createState() => _ForgotViewState();
}

class _ForgotViewState extends State<_ForgotView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<ForgotPasswordBloc>().add(
        ForgotPasswordSubmitted(_email.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state.status == UIStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.resetLinkSent)),
              );
              Navigator.of(context).maybePop();
            } else if (state.status == UIStatus.error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            // With the keyboard up there is far less height than this column
            // wants; scroll instead of overflowing, and let the `Spacer` push
            // the footer down only when there is room to spare.
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.screenH.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: AppDimens.xl.h),
                          const AuthLogo(),
                          SizedBox(height: AppDimens.md.h),
                          Text(
                            AppStrings.forgotTitle,
                            style: AppTextStyles.h1,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppDimens.xs.h),
                          Text(
                            AppStrings.forgotSubtitle,
                            style: AppTextStyles.pageSubtitle,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: AppDimens.xl.h),
                          AuthTextField(
                            label: AppStrings.email,
                            controller: _email,
                            hint: 'sara@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => validateEmail(v ?? '', context),
                          ),
                          SizedBox(height: AppDimens.lg.h),
                          PrimaryButton(
                            label: AppStrings.sendResetLink,
                            loading: state.status == UIStatus.loading,
                            onPressed: () => _submit(context),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              AppStrings.backToLogin,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyStrong.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          SizedBox(height: AppDimens.md.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
