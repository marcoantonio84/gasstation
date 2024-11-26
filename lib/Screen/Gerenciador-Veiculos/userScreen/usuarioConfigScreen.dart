import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsuarioConfigScreen extends StatefulWidget {
  const UsuarioConfigScreen({super.key});

  @override
  _UsuarioConfigScreenState createState() => _UsuarioConfigScreenState();
}

class _UsuarioConfigScreenState extends State<UsuarioConfigScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController usernameController = TextEditingController();
  bool isEditing = false;
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    User? user = _auth.currentUser;
    if (user != null) {
      usernameController.text = user.displayName ?? '';
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _saveChanges() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: usernameController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Informações salvas com sucesso!'),
        ));
        _toggleEdit();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao salvar as informações: $e'),
      ));
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _auth.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('E-mail de redefinição de senha enviado!'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao enviar o e-mail: $e'),
      ));
    }
  }

  Future<void> _reauthenticateAndDeleteAccount() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String password = passwordController.text;

      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        await user.reauthenticateWithCredential(credential);

        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conta excluída com sucesso!'),
        ));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao excluir conta: ${e.message}'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro inesperado: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Configuração de Usuário',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  Icon(
                    Icons.account_circle,
                    size: 120.0,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
            Text('Nome de Usuário:', style: TextStyle(fontSize: 18)),
            isEditing
                ? TextField(
                    controller: usernameController,
                    decoration: InputDecoration(hintText: 'Digite o nome de usuário'),
                  )
                : Text(
                    usernameController.text.isEmpty ? 'Nenhum nome definido' : usernameController.text,
                    style: TextStyle(fontSize: 18),
                  ),
            SizedBox(height: 20),
            Text('E-mail:', style: TextStyle(fontSize: 18)),
            Text(
              _auth.currentUser?.email ?? 'E-mail não disponível',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleEdit,
                  child: Text(isEditing ? 'Cancelar' : 'Editar'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isEditing ? _saveChanges : null,
                  child: Text('Salvar'),
                ),
              ],
            ),
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(
                      'Alterar Senha',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Confirmar Exclusão'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Digite sua senha para confirmar a exclusão da conta:'),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(hintText: 'Senha'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); 
                                },
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _reauthenticateAndDeleteAccount(); 
                                },
                                child: Text('Confirmar', style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Excluir Conta', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
