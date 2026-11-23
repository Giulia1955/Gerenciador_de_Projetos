import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/social_button.dart';
import '../components/my_lottie.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Validação do formato do email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  // Exibe mensagens de alerta
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Recuperação de senha
  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showAlert('Digite seu email primeiro.');
      return;
    }

    if (!isValidEmail(email)) {
      showAlert('Informe um endereço de email válido.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      showAlert('Enviamos um link para seu email!');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      showAlert(switch (e.code) {
        'invalid-email' => 'O endereço de email informado é inválido.',
        'user-not-found' => 'Não encontramos uma conta com esse email.',
        _ => 'Não foi possível enviar o email de recuperação.',
      });
    }
  }

  // Login
  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Verifica se o email está vazio
    if (email.isEmpty) {
      showAlert('Digite seu email.');
      return;
    }

    // Valida o formato do email
    if (!isValidEmail(email)) {
      showAlert('Informe um endereço de email válido.');
      return;
    }

    // Verifica se a senha está vazia
    if (password.isEmpty) {
      showAlert('Digite sua senha.');
      return;
    }

    // Exibe o carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pop(context); // Fecha o loading
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // Fecha o loading

      showAlert(switch (e.code) {
        'invalid-credential' => 'Email ou senha incorretos.',
        'user-disabled' => 'Esta conta foi desativada.',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
        'invalid-email' => 'O endereço de email informado é inválido.',
        _ => 'Não foi possível entrar. Tente novamente.',
      });
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      showAlert('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Animação Lottie
                const MyLottie(
                  animation: 'assets/animation/Owl.json',
                  height: 200,
                  width: 200,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Bem-vindo de volta!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // Campo de email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 15),

                // Campo de senha
                MyTextField(
                  controller: passwordController,
                  hintText: 'Senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                // Recuperação de senha
                TextButton(
                  onPressed: forgotPassword,
                  child: const Text('Esqueceu a senha?'),
                ),

                // Botão de login
                MyButton(
                  onTap: signIn,
                  text: 'Entrar',
                  icon: Icons.login,
                ),

                const SizedBox(height: 25),

                const Text('ou continue com'),

                const SizedBox(height: 15),

                // Login social
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      SocialButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // Navegação para cadastro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Registre-se agora'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
