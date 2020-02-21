import 'package:flutter/material.dart';
import 'blocs/home_bloc.dart';

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
  HomeBloc bloc = HomeBloc();
  TextEditingController _controllerTarefa = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc.inicializarListaTarefas();
  }

  Widget _criarItemLista(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          bloc.removerTarefa(index);
          final snackbar = SnackBar(
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 5),
            content: Text("Tarefa removida!"),
            action: SnackBarAction(
              textColor: Colors.yellow,
              label: "Desfazer",
              onPressed: () {
                bloc.recuperarUltimaTarefaExcluida(index);
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
        title: Text(bloc.listaTarefas[index]['titulo']),
        value: bloc.listaTarefas[index]['realizada'],
        onChanged: (valorAlterado) {
          bloc.atualizarTarefa(index, valorAlterado);
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
              child: StreamBuilder<int>(
                stream: bloc.minhaStream,
                initialData: 0,
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data,
                    itemBuilder: _criarItemLista,
                  );
                },
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
                    controller: _controllerTarefa,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        _controllerTarefa.text = "";
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Salvar"),
                      onPressed: () {
                        bloc.salvarTarefa(_controllerTarefa.text);
                        _controllerTarefa.text = "";
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.add,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.menu,
                ),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
