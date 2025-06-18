import 'package:flutter/material.dart';

class BoardDetailPage extends StatefulWidget {
  final int boardId;
  final String boardName;

  const BoardDetailPage({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: const Center(
        // No próximo passo, construiremos a visualização de listas/colunas aqui.
        child: Text('Em breve: Listas de tarefas deste quadro.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
        onPressed: () {
          // TODO: Implementar diálogo para adicionar nova lista
        },
      ),
    );
  }
}
