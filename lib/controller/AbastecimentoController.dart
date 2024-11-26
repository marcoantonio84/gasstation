import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenciamento_veiculos/Model/Abastecimento.dart';
import 'package:gerenciamento_veiculos/Model/Veiculo.dart';
import 'package:gerenciamento_veiculos/controller/VeiculoController.dart';

class AbastecimentoController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> cadastrarAbastecimento(Abastecimento abastecimento) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("Nenhum usuário logado.");
        return false;
      }

      String usuarioId = user.uid;

      CollectionReference abastecimentos = _firestore.collection('abastecimentos');

      Map<String, dynamic> dadosAbastecimento = {
        'usuarioId': usuarioId,
        'dataAbastecimento': abastecimento.dataAbastecimento,
        'quantidadeLitros': abastecimento.quantidadeLitros,
        'km': abastecimento.km,
        'veiculoId': abastecimento.veiculo.id,
      };

      await abastecimentos.add(dadosAbastecimento);

      double mediaConsumoNovo = (abastecimento.km - abastecimento.veiculo.kmAtual) /
          abastecimento.quantidadeLitros;
      abastecimento.veiculo.kmAtual = abastecimento.km;

      VeiculoController veiculoController = VeiculoController();
      await veiculoController.atualizarKmConsumoVeiculo(
          abastecimento.veiculo, mediaConsumoNovo);

      abastecimento.veiculo.abastecimentos.add(abastecimento);

      return true;
    } catch (e) {
      print("Erro ao cadastrar abastecimento: $e");
      return false;
    }
  }

  Future<List<Abastecimento>> buscarAbastecimentoPorVeiculo() async {
    try {
      VeiculoController veiculoController = VeiculoController();

      List<Veiculo> veiculos = await veiculoController.buscarVeiculosUsuario();

      List<Abastecimento> listaAbastecimentos = [];

      for (var veiculo in veiculos) {
        CollectionReference abastecimentos = _firestore.collection('abastecimentos');

        QuerySnapshot querySnapshot = await abastecimentos
            .where('veiculoId', isEqualTo: veiculo.id)
            .orderBy('dataAbastecimento', descending: true)
            .get();

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic>? dados = doc.data() as Map<String, dynamic>?;

          if (dados != null) {
            listaAbastecimentos.add(Abastecimento.fromMap(dados, veiculo.id, veiculo.nome));
          } else {
            print("Documento com dados nulos encontrado: ${doc.id}");
          }
        }
      }

      return listaAbastecimentos;
    } catch (e) {
      print("Erro ao buscar abastecimentos: $e");
      return [];
    }
  }
}
