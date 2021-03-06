import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:feedhub/repositories/auth/auth_repository.dart';
import 'package:feedhub/screens/login/cubit/login_cubit.dart';
import 'package:feedhub/screens/signup/signup_screen.dart';
import 'package:feedhub/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  // we want the login screen to slide over the splash screen so instead of using material page route we have to use the Page Route builder in order to make the screen appear on top of the splash screen
  static Route route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (context, _, __) => BlocProvider<LoginCubit>(
        create: (_) =>
            LoginCubit(authRepository: context.read<AuthRepository>()),
        child: LoginScreen(),
      ),
    );
  }

  // USed to access the state of the form to validate all the form fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // Prohibits the users from poping the screen
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.error) {
              showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(title: "Error", content: state.failure.message),
              );
            }
          },
          builder: (context, state) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize
                              .min, // Controls the height of the card
                          children: [
                            const Text(
                              'Instagram',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            TextFormField(
                              decoration: InputDecoration(hintText: 'Email'),
                              onChanged: (value) => context
                                  .read<LoginCubit>()
                                  .emailChanged(value),
                              validator: (value) => !value.contains('@')
                                  ? 'Please enter a valid email'
                                  : null,
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            TextFormField(
                              decoration: InputDecoration(hintText: 'Password'),
                              obscureText: true,
                              onChanged: (value) => context
                                  .read<LoginCubit>()
                                  .passwordChanged(value),
                              validator: (value) => value.length < 6
                                  ? 'Must be atleast 6 characters.'
                                  : null,
                            ),
                            const SizedBox(
                              height: 28.0,
                            ),
                            ElevatedButton(
                              onPressed: () => _submitForm(
                                context,
                                state.status == LoginStatus.submitting,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 1.0,
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                              ),
                              child: Text("Log In"),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(SignupScreen.routeName),
                              style: ElevatedButton.styleFrom(
                                elevation: 1.0,
                                primary: Colors.grey[200],
                                onPrimary: Colors.black,
                              ),
                              child: Text("No account? Sign up"),
                            ),
                          ],
                        ),
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

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState.validate() && !isSubmitting) {
      context.read<LoginCubit>().logInWithCredentials();
    }
  }
} // LogIn screen state will be handled by Login cubit
