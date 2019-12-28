import 'package:app_crud/helper/AnotacaoHelper.dart';
import 'package:app_crud/model/Anotacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirCadastro( { Anotacao anotacao } ){

    String textoSalvarAtualizar = "";
    if(anotacao == null){
      _titleController.text = "";
      _descController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      _titleController.text = anotacao.titulo;
      _descController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("$textoSalvarAtualizar anotação"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Título",
                  hintText: "Digite o título"
                ),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                    labelText: "Descrição",
                    hintText: "Digite a descrição"
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(
                textoSalvarAtualizar,
                style: TextStyle(
                  color: Colors.blue
                ),
              ),
              onPressed: (){
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  _recuperarAnotacoes() async {

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemporaria = List<Anotacao>();

    for (var item in anotacoesRecuperadas){
      Anotacao anotacao = Anotacao.fromMap( item );
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });

    listaTemporaria = null;
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _titleController.text;
    String descricao = _descController.text;

    if(anotacaoSelecionada == null){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _titleController.clear();
    _descController.clear();
    _recuperarAnotacoes();
  }

  _formatarData(String data){
    initializeDateFormatting("pt-BR");

    // Year -> y // month -> M // Day -> d
    // Hour -> H // minute -> m // second -> s
    // var formatador = DateFormat("d/MM/y - H:m:s");
    var formatador = DateFormat.yMd("pt-BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Anotações"),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index){

                  final anotacao = _anotacoes[index];

                  return Card(
                    child: ListTile(
                      title: Text(anotacao.titulo),
                      subtitle: Text("${_formatarData(anotacao.data)} - ${anotacao.descricao}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                                Icons.edit,
                              color: Colors.greenAccent,
                            ),
                            onPressed: (){
                              _exibirCadastro( anotacao: anotacao );
                            }
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                              color: Colors.redAccent,
                            ),
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    title: Text("Deseja excluir a tarefa ?"),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                            "Não",
                                          style: TextStyle(
                                            color: Colors.redAccent
                                          ),
                                        )
                                      ),
                                      FlatButton(
                                        onPressed: (){
                                          _removerAnotacao( anotacao.id );
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            "Sim",
                                          style: TextStyle(
                                            color: Colors.white70
                                          ),
                                        )
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                  );
                }
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
        onPressed: (){
          _exibirCadastro();
        },
      ),
    );
  }
}
