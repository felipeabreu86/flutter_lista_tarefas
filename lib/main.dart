import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimaTarefaremovida;
  TextEditingController _controllerTarefa = TextEditingController();

  ///* Recupera o path do arquivo que irá armazenar os dados em formato json
  Future<File> _getFile() async {
    var diretorio;
    if (Platform.isAndroid) {
      diretorio = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      diretorio = await getApplicationDocumentsDirectory();
    }
    var arquivo = File("${diretorio.path}/dados.json");
    return arquivo;
  }

  ///* Salva a lista de tarefas no arquivo
  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  ///* Salva a tarefa na lista de tarefas e chama o método que salva no arquivo
  _salvarTarefa() {
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = _controllerTarefa.text;
    tarefa["realizada"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  ///* Lê o arquivo json armazenado e o retorna em formato String
  Future<String> _lerArquivo() async {
    try {
      var arquivo = await _getFile();
      if (await arquivo.exists()) {
        return arquivo.readAsString();
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  ///* Inicializa a tela
  ///* Lê o arquivo e carrega a lista de tarefas
  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      if (dados != null) {
        setState(() {
          _listaTarefas = json.decode(dados);
        });
      }
    });
  }

  Widget _criarItemLista(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _ultimaTarefaremovida = _listaTarefas[index];
          _listaTarefas.removeAt(index);
          _salvarArquivo();
          final snackbar = SnackBar(
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 5),
            content: Text("Tarefa removida!"),
            action: SnackBarAction(
              textColor: Colors.yellow,
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _listaTarefas.insert(index, _ultimaTarefaremovida);
                });
                _salvarArquivo();
              },
            ),
          );
          Scaffold.of(context).showSnackBar(snackbar);
        }
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]['titulo']),
        value: _listaTarefas[index]['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            _listaTarefas[index]['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          centerTitle: false,
          title: Text("Lista de Tarefas"),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: _criarItemLista,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                    controller: _controllerTarefa,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
