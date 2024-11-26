import 'package:flutter/material.dart';
import 'package:gerenciamento_veiculos/Model/Veiculo.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/veiculoScreen/editarVeiculoDialog.dart';
import 'package:gerenciamento_veiculos/Screen/Gerenciador-Veiculos/veiculoScreen/veiculoCard.dart';
import 'package:gerenciamento_veiculos/controller/VeiculoController.dart';

class Listaveiculos extends StatefulWidget {
  const Listaveiculos({super.key});

  @override
  _ListaveiculosState createState() => _ListaveiculosState();
}

class _ListaveiculosState extends State<Listaveiculos> {
  late VeiculoController veiculoController;
  late Future<List<Veiculo>> veiculosFuture;

  @override
  void initState() {
    super.initState();
    veiculoController = VeiculoController();
    veiculosFuture = veiculoController.buscarVeiculosUsuario();
  }

  void atualizarVeiculos() {
    setState(() {
      veiculosFuture = veiculoController.buscarVeiculosUsuario();
    });
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
              child: const Text(
                'Meus Veículos',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Veiculo>>(
                future: veiculosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum veículo encontrado.'));
                  }

                  final veiculos = snapshot.data!;

                  return ListView.builder(
                    itemCount: veiculos.length,
                    itemBuilder: (context, index) {
                      return VeiculoCard(
                        veiculo: veiculos[index],
                        onEdit: () {
                          showEditDialog(
                            context,
                            veiculos[index],
                            (editedVeiculo) {
                              veiculoController.editarVeiculo(
                                veiculos[index].id, 
                                editedVeiculo.nome,
                                editedVeiculo.marca,
                                editedVeiculo.ano,
                                editedVeiculo.placa,
                              ).then((_) {
                                atualizarVeiculos();
                              });
                            },
                            (deletedVeiculo) {
                              veiculoController.deletarVeiculo(deletedVeiculo.id).then((_) {
                                atualizarVeiculos();
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
