import 'dart:async';
import 'dart:convert';
import 'package:flutter_lista_tarefas/services/ioService.dart';

class HomeBloc {
  final _blocController = StreamController<int>();
  static const String _NOME_ARQUIVO = "dados";
  List listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaremovida;

  Stream<int> get minhaStream => _blocController.stream;

  //* Lê o arquivo salvo e preenche a lista de tarefa com as tarefas existentes
  void inicializarListaTarefas() {
    IOService.lerArquivo(_NOME_ARQUIVO).then((dados) {
      if (dados != null) {
        listaTarefas = json.decode(dados);
        _blocController.sink.add(listaTarefas.length);
      }
    });
  }

  //* Adiciona uma tarefa à lista de tarefas e atualiza o controller
  void _adicionarTarefa(Map<String, dynamic> tarefa) {
    listaTarefas.add(tarefa);
    _blocController.sink.add(listaTarefas.length);
  }

  ///* Adiciona a tarefa incluída pelo usuário na lista e a salva no arquivo
  void salvarTarefa(String descricaoTarefa) {
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = descricaoTarefa;
    tarefa["realizada"] = false;
    _adicionarTarefa(tarefa);
    _salvarArquivo();
  }

  ///* Salva a lista de tarefas no arquivo
  void _salvarArquivo() async {
    var arquivo = await IOService.getFile(_NOME_ARQUIVO);
    String dados = json.encode(listaTarefas);
    arquivo.writeAsString(dados);
  }

  //* Remove a tarefa da lista de taredas e do arquivo
  //* Armazena a última tarefa removida caso o usuário queira desfazer a ação
  void removerTarefa(int index) {
    _ultimaTarefaremovida = listaTarefas[index];
    listaTarefas.removeAt(index);
    _blocController.sink.add(listaTarefas.length);
    _salvarArquivo();
  }

  //* Adiciona novamente a última tarefa removida na lista e no arquivo
  void recuperarUltimaTarefaExcluida(int index) {
    listaTarefas.insert(index, _ultimaTarefaremovida);
    _blocController.sink.add(listaTarefas.length);
    _salvarArquivo();
  }

  //* Atualiza o estado de uma tarefa específica na lista e no arquivo
  void atualizarTarefa(int index, bool valorAlterado) {
    listaTarefas[index]['realizada'] = valorAlterado;
    _blocController.sink.add(listaTarefas.length);
    _salvarArquivo();
  }

  //* Fecha o StreamController
  fecharStream() {
    _blocController.close();
  }
}
