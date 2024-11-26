import 'package:flutter/material.dart';
import 'package:gerenciamento_veiculos/controller/VeiculoController.dart'; 

class AdicionarVeiculosScreen extends StatefulWidget {
  const AdicionarVeiculosScreen({super.key});

  @override
  _AdicionarVeiculosScreenState createState() => _AdicionarVeiculosScreenState();
}

class _AdicionarVeiculosScreenState extends State<AdicionarVeiculosScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _kmController = TextEditingController(); 

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _adicionarVeiculo(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      VeiculoController controller = VeiculoController();

      bool sucesso = await controller.adicionarVeiculo(
        _nomeController.text,
        _marcaController.text,
        _anoController.text,
        _placaController.text,
        int.tryParse(_kmController.text) ?? 0, 
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sucesso ? 'Veículo adicionado com sucesso!' : 'Erro ao adicionar veículo.'),
        ),
      );

      if (sucesso) {
        _nomeController.clear();
        _marcaController.clear();
        _anoController.clear();
        _placaController.clear();
        _kmController.clear(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Adicionar Novo Veículo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Veículo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca do Veículo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a marca do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _anoController,
                decoration: const InputDecoration(
                  labelText: 'Ano do Veículo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ano do veículo.';
                  } else if (int.tryParse(value) == null) {
                    return 'Por favor, insira um ano válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa do Veículo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a placa do veículo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Km Atual do Veículo',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o km atual do veículo.';
                  } else if (int.tryParse(value) == null) {
                    return 'Por favor, insira um valor de km válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.blue, 
                  ),
                  onPressed: () => _adicionarVeiculo(context),
                  child: const Text('Adicionar Veículo', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
