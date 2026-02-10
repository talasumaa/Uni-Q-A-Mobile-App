import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../utils/snack.dart';

class AddAnswerScreen extends StatefulWidget {
  final String questionId;

  const AddAnswerScreen({super.key, required this.questionId});

  @override
  State<AddAnswerScreen> createState() => _AddAnswerScreenState();
}

class _AddAnswerScreenState extends State<AddAnswerScreen> {
  final bodyCtrl = TextEditingController();

  @override
  void dispose() {
    bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _post(AppState state) async {
    final body = bodyCtrl.text.trim();
    if (body.isEmpty) {
      snack(context, "Please enter an answer.");
      return;
    }

    await state.addAnswer(questionId: widget.questionId, body: body);

    if (!mounted) return;
    Navigator.pop(context);
    snack(context, "Answer posted.");
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write an answer"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            "Posting as ${state.currentUser.displayName}",
            style: tt.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyCtrl,
            minLines: 10,
            maxLines: 16,
            decoration: const InputDecoration(
              labelText: "Answer",
              hintText:
                  "Explain clearly. Structure helps (short steps, example, key point).",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _post(state),
            icon: const Icon(Icons.send_outlined),
            label: const Text("Post answer"),
          ),
        ],
      ),
    );
  }
}
