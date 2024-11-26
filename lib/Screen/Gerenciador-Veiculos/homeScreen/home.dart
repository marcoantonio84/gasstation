import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/abastecimentoScreen/abastecimentoScreen.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/userScreen/usuarioConfigScreen.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/veiculoScreen/adicionarVeiculosScreen.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/veiculoScreen/listaVeiculosScreen.dart';
import 'package:gerenciamento_veiculos/Screen/Login-Cadastro/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  User? user = FirebaseAuth.instance.currentUser;

  Widget _getBodyContent(int index) {
    switch (index) {
      case 0:
        return const Listaveiculos();
      case 1:
        return const AdicionarVeiculosScreen();
      case 2:
        return const AbastecimentoScreen();
      case 3: 
        return const UsuarioConfigScreen();
      case 4:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confirmarDeslogar(context);
        });
        return const Listaveiculos();
      default:
        return Scaffold(
        body: Center(
          child: Text('Erro desconhecido!', style: TextStyle(fontSize: 24, color: Colors.red)),
        ),
      );
  }
}

  Future<void> _confirmarDeslogar(BuildContext context) async{
    bool? confirmarDeslogar = await showDialog<bool>(context: context,
     builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Você tem certeza que deseja deslogar?'),
        actions: <Widget[
          TextButton(onPressed: (){
            Navigator.of(context).pop(false);
          }, child: const Text('Cancelar'),
          ),
          TextButton(onPressed: (){
            Navigator.of(context).pop(true);
          }, 
          style: TextButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Confirmar', style: TextStyle(color: Colors.white),))
        ],
      );
     }
     );
     if (confirmarDeslogar == true) {
      await _logout(context);
     }
  }

  Future<void> _logout(BuildContext context) async{
    try{
      await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deslogado com sucesso')),
    );
          Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );

    }catch (e){
          ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao deslogar: $e')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Gerenciamento de Veículos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8), 
                  if (user != null)
                    Text(
                      'Olá, ${user?.displayName ?? user?.email ?? 'Usuário'}',  
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.car_repair),
              title: Text('Meus Veículos'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Adicionar Veículo'),
              
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Histórico de Abastecimentos'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:  Icon(Icons.person),
              title: Text('Perfil'),
              onTap: (){
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: (){
                setState(() {
                  _selectedIndex = 4;
                });
              },
            )
          ],
        ),
      ),
      body: _getBodyContent(_selectedIndex), 
    );
  }
}
