import 'package:flutter/material.dart';
import 'package:gerenciamento_veiculos/Model/Abastecimento.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/abastecimentoScreen/abastecimentoCard.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/abastecimentoScreen/abastecimentoDialog.dart';
import 'package:gerenciamento_veiculos/controller/AbastecimentoController.dart';

class AbastecimentoScreen extends StatefulWidget {
  const AbastecimentoScreen({super.key});

  @override
  _AbastecimentoScreenState createState() => _AbastecimentoScreenState();
}

class _AbastecimentoScreenState extends State<AbastecimentoScreen> {
  final AbastecimentoController abastecimentoController = AbastecimentoController();
  late Future<List<Abastecimento>> _abastecimentosFuture;

  @override
  void initState() {
    super.initState();
    _abastecimentosFuture = abastecimentoController.buscarAbastecimentoPorVeiculo();
  }

  void _recarregarAbastecimentos() {
    setState(() {
      _abastecimentosFuture = abastecimentoController.buscarAbastecimentoPorVeiculo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Histórico de Abastecimento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool? result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AbastecimentoDialog();
                    },
                  );

                  if (result == true) {
                    _recarregarAbastecimentos();
                  }
                },
                child: Text(
                  'Cadastrar Novo Abastecimento',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Abastecimento>>(
                  future: _abastecimentosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Carregando histórico de abastecimento...'),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar abastecimentos'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Nenhum abastecimento encontrado'));
                    } else {
                      List<Abastecimento> abastecimentos = snapshot.data!;
                      return ListView.builder(
                        itemCount: abastecimentos.length,
                        itemBuilder: (context, index) {
                          Abastecimento abastecimento = abastecimentos[index];
                          return AbastecimentoCard(abastecimento: abastecimento); 
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}
