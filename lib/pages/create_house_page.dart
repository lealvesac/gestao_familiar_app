import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';
import 'package:gestao_familiar_app/pages/invite_page.dart';

class CreateHousePage extends StatefulWidget {
  final VoidCallback onHouseCreated;
  const CreateHousePage({super.key, required this.onHouseCreated});

  @override
  State<CreateHousePage> createState() => _CreateHousePageState();
}

class _CreateHousePageState extends State<CreateHousePage> {
  final _formKey = GlobalKey<FormState>();
  final _houseNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createHouse() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final houseName = _houseNameController.text.trim();

    try {
      final response = await supabase
          .rpc(
            'create_house_and_assign_owner',
            params: {'house_name': houseName},
          )
          .single(); // .single() para pegar o único resultado da tabela retornada

      if (mounted) {
        final inviteCode = response['invite_code'];
        // Navega para a tela de convite, passando o código gerado
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => InvitePage(
              inviteCode: inviteCode,
              onDone: widget.onHouseCreated,
            ),
          ),
        );
      }
    } catch (e) {
      //... (código de erro)
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Casa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _houseNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Casa',
                hintText: 'Ex: Família Silva, Apê 101',
              ),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createHouse,
                    child: const Text('Criar e Convidar'),
                  ),
          ],
        ),
      ),
    );
  }
}
