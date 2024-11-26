import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AlterarSenha extends StatefulWidget {
  const AlterarSenha({super.key});

  @override
  State<AlterarSenha> createState() => _AlterarSenhaState();
}

class _AlterarSenhaState extends State<AlterarSenha> {
  final TextEditingController _emailController = TextEditingController();
  String? _statusMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(
          child: Text(
            'Alterar Senha',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        automaticallyImplyLeading: false,

      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Informe seu e-mail para alterar a senha',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,  // Cor do texto alterada para preto
              ),
            ),
            SizedBox(height: 30.0),

            // Campo de email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 24.0),

            // Mensagem de erro ou sucesso
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('sucesso') ? Colors.green : Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Botão de enviar link para alteração de senha
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Enviar Link',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para enviar o e-mail de redefinição de senha
  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null; // Limpa a mensagem de erro/aviso antes de tentar enviar
    });

    try {
      final auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: email);
      setState(() {
        _statusMessage = 'Link de redefinição de senha enviado com sucesso! Verifique seu e-mail.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'Erro: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
