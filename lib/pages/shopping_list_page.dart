// ARQUIVO COMPLETO E CORRIGIDO: lib/pages/shopping_list_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import necessário

class ShoppingListPage extends StatefulWidget {
  final String houseId;
  const ShoppingListPage({super.key, required this.houseId});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _getItems();

    // SINTAXE DE TEMPO REAL CORRIGIDA
    _channel = supabase
        .channel('public:shopping_list_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_list_items',
          callback: (payload) {
            // Quando uma mudança ocorre no banco, esta função é chamada.
            // A linha abaixo é útil para ver as mudanças no console de debug.
            print('Mudança detectada no realtime: ${payload.toString()}');
            // Buscamos os itens novamente para atualizar a UI.
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
    // Para atualizações em tempo real, não queremos mostrar o loading piscando.
    // O loading só deve aparecer na primeira carga da tela.
    if (_isLoading) {
      try {
        final response = await supabase
            .from('shopping_list_items')
            .select()
            .eq('house_id', widget.houseId)
            .order('created_at');
        if (mounted) {
          setState(() => _items = List<Map<String, dynamic>>.from(response));
        }
      } catch (e) {
        debugPrint("Erro ao buscar itens de compra: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Para atualizações subsequentes (via realtime), buscamos os dados sem mostrar o loading.
      final response = await supabase
          .from('shopping_list_items')
          .select()
          .eq('house_id', widget.houseId)
          .order('created_at');
      if (mounted) {
        setState(() => _items = List<Map<String, dynamic>>.from(response));
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

  void _showAddItemDialog() {
    final itemController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Item de Compra'),
          content: TextFormField(
            controller: itemController,
            decoration: const InputDecoration(labelText: 'O que comprar?'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final itemContent = itemController.text.trim();
                if (itemContent.isEmpty) return;

                try {
                  await supabase.from('shopping_list_items').insert({
                    'content': itemContent,
                    'house_id': widget.houseId,
                    'profile_id': supabase.auth.currentUser!.id,
                  });
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  debugPrint("Erro ao criar item de compra: $e");
                }
              },
              child: const Text('Adicionar'),
            ),
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
          : _items.isEmpty
          ? const Center(
              child: Text(
                'A lista de compras está vazia!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
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
                    setState(() {
                      item['is_purchased'] = newValue;
                    });
                    _toggleItemPurchased(item['id'], newValue);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add_shopping_cart),
        tooltip: 'Adicionar item',
      ),
    );
  }
}
