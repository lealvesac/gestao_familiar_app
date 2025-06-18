// CÓDIGO FINAL E CORRIGIDO: lib/pages/shopping_list_detail_page.dart

import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingListDetailPage extends StatefulWidget {
  final int listId;
  final String listName;

  const ShoppingListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends State<ShoppingListDetailPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _getItems();

    // SINTAXE DE TEMPO REAL CORRIGIDA
    _channel = supabase
        .channel('public:shopping_list_items:list_id=eq.${widget.listId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_list_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'list_id',
            value: widget.listId,
          ),
          callback: (payload) {
            _getItems();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    supabase.removeChannel(_channel!);
    super.dispose();
  }

  Future<void> _getItems() async {
    // Para não mostrar o loading piscando a cada atualização do realtime
    if (_isLoading == false && mounted) {
      final response = await supabase
          .from('shopping_list_items')
          .select()
          .eq('list_id', widget.listId)
          .order('created_at');
      setState(() {
        _items = List<Map<String, dynamic>>.from(response);
      });
      return;
    }

    // Lógica para a primeira carga
    try {
      final response = await supabase
          .from('shopping_list_items')
          .select()
          .eq('list_id', widget.listId)
          .order('created_at');
      if (mounted) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Erro ao buscar itens de compra: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleItemPurchased(int itemId, bool newStatus) async {
    try {
      await supabase
          .from('shopping_list_items')
          .update({'is_purchased': newStatus})
          .eq('id', itemId);
    } catch (e) {
      debugPrint("Erro ao atualizar item de compra: $e");
    }
  }

  Future<void> _showAddItemDialog() async {
    final itemController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void submit() async {
      if (formKey.currentState!.validate()) {
        await _addItem(itemController.text.trim());
        if (mounted) Navigator.of(context).pop();
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Item'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: itemController,
              decoration: const InputDecoration(labelText: 'Nome do item'),
              autofocus: true,
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'O nome é obrigatório'
                  : null,
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: submit, child: const Text('Adicionar')),
          ],
        );
      },
    );
  }

  Future<void> _addItem(String content) async {
    try {
      await supabase.from('shopping_list_items').insert({
        'content': content,
        'list_id': widget.listId,
        'profile_id': supabase.auth.currentUser!.id,
      });
      // Não precisamos chamar _getItems() aqui, o realtime cuida disso!
    } catch (e) {
      debugPrint("Erro ao adicionar item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.listName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _getItems,
              child: _items.isEmpty
                  ? const Center(child: Text('Nenhum item nesta lista.'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return CheckboxListTile(
                          title: Text(
                            item['content'],
                            style: TextStyle(
                              decoration: item['is_purchased']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: item['is_purchased'] ? Colors.grey : null,
                            ),
                          ),
                          value: item['is_purchased'],
                          onChanged: (bool? newValue) {
                            if (newValue == null) return;
                            setState(() => item['is_purchased'] = newValue);
                            _toggleItemPurchased(item['id'], newValue);
                          },
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
