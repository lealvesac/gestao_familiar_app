import 'package:flutter/material.dart';
import 'package:gestao_familiar_app/main.dart';

class JoinHousePage extends StatefulWidget {
  final VoidCallback onHouseJoined;
  const JoinHousePage({super.key, required this.onHouseJoined});

  @override
  State<JoinHousePage> createState() => _JoinHousePageState();
}

class _JoinHousePageState extends State<JoinHousePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

Future<void> _joinHouse() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final inviteCode = _codeController.text.trim();

    try {
      await supabase.rpc(
        'join_house_with_code',
        params: {'p_invite_code': inviteCode},
      );

      if (mounted) {
        // 1. Primeiro, chamamos a função de callback para atualizar a HomePage por trás
        widget.onHouseJoined();

        // 2. Depois, removemos todas as telas do "wizard" (JoinHousePage, NoHousePage)
        //    da pilha de navegação, revelando a HomePage que já foi atualizada
        //    para mostrar o painel da casa.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("ERRO AO ENTRAR NA CASA: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('inválido')
                  ? 'Código de convite inválido.'
                  : 'Ocorreu um erro ao entrar na casa.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // Garante que o loading pare em caso de erro
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar em uma Casa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Código de Convite'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Insira o código' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _joinHouse,
                    child: const Text('Entrar na Casa'),
                  ),
          ],
        ),
      ),
    );
  }
}
