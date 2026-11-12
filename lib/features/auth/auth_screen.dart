import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../state/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _signUp = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    FocusScope.of(context).unfocus();
    if (_signUp) {
      await auth.signUp(_email.text, _password.text, _username.text);
    } else {
      await auth.signIn(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: context.tint,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              CupertinoIcons.barcode_viewfinder,
                              color: CupertinoColors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _signUp ? 'Create Account' : 'Welcome Back',
                            style: IosText.largeTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Scan food, see what's really inside, and keep "
                            'track of what you find.',
                            style: IosText.body.copyWith(
                              color: context.secondaryLabelColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (_signUp)
                          CupertinoTextFormFieldRow(
                            controller: _username,
                            prefix: const _FieldLabel('Username'),
                            placeholder: 'Choose a name',
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            validator: (v) {
                              final s = v?.trim() ?? '';
                              return s.length < 3 || s.length > 24
                                  ? 'Use 3–24 characters'
                                  : null;
                            },
                          ),
                        CupertinoTextFormFieldRow(
                          controller: _email,
                          prefix: const _FieldLabel('Email'),
                          placeholder: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) =>
                              RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(v?.trim() ?? '')
                              ? null
                              : 'Enter a valid email',
                        ),
                        CupertinoTextFormFieldRow(
                          controller: _password,
                          prefix: const _FieldLabel('Password'),
                          placeholder: 'At least 6 characters',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: [
                            _signUp
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) => (v ?? '').length < 6
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                      ],
                    ),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 4, 32, 0),
                        child: Text(
                          auth.error!,
                          style: IosText.footnote.copyWith(
                            color: context.destructive,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: CupertinoButton.filled(
                        onPressed: auth.busy ? null : _submit,
                        child: auth.busy
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : Text(_signUp ? 'Create Account' : 'Sign In'),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => setState(() {
                        _signUp = !_signUp;
                        auth.error = null;
                      }),
                      child: Text(
                        _signUp
                            ? 'Already have an account? Sign In'
                            : 'New here? Create an Account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 84, child: Text(text, style: IosText.body));
}
