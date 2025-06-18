// ARQUIVO ATUALIZADO: lib/pages/shopping_list_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/shopping_list_detail_page.dart'; // Nova página

class ShoppingListPage extends StatefulWidget {
  final String houseId;
  const ShoppingListPage({super.key, required this.houseId});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<Map<String, dynamic>> _shoppingLists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getShoppingLists();
  }

  Future<void> _getShoppingLists() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('shopping_lists')
          .select()
          .eq('house_id', widget.houseId)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _shoppingLists = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar listas de compras: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddListDialog() async {
    final listNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void submit() async {
      if (formKey.currentState!.validate()) {
        try {
          await supabase.from('shopping_lists').insert({
            'name': listNameController.text.trim(),
            'house_id': widget.houseId,
          });
          if (mounted) Navigator.of(context).pop();
          _getShoppingLists();
        } catch (e) {
          debugPrint("Erro ao criar lista de compras: $e");
        }
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Criar Nova Lista de Compras'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: listNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Lista (Ex: Mercado)',
              ),
              autofocus: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'O nome é obrigatório.'
                  : null,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: submit, child: const Text('Criar')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getShoppingLists,
              child: _shoppingLists.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma lista de compras criada. Crie a primeira!',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _shoppingLists.length,
                      itemBuilder: (context, index) {
                        final list = _shoppingLists[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.list_alt_outlined),
                            title: Text(list['name']),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ShoppingListDetailPage(
                                    listId: list['id'],
                                    listName: list['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
        onPressed: _showAddListDialog,
      ),
    );
  }
}
