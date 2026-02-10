import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../utils/snack.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  @override
  void dispose() {
    titleCtrl.dispose();
    bodyCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    final parts = raw
        .split(RegExp(r"[,\n ]+"))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.length > 18 ? e.substring(0, 18) : e)
        .toList();
    return parts.toSet().toList();
  }

  Future<void> _post(AppState state) async {
    final title = titleCtrl.text.trim();
    final body = bodyCtrl.text.trim();
    final tags = _parseTags(tagsCtrl.text);

    if (title.isEmpty) {
      snack(context, "Please add a title.");
      return;
    }
    if (body.isEmpty) {
      snack(context, "Please add some context.");
      return;
    }
    if (tags.isEmpty) {
      snack(context, "Please add at least one tag.");
      return;
    }

    await state.addQuestion(title: title, body: body, tags: tags);

    if (!mounted) return;
    titleCtrl.clear();
    bodyCtrl.clear();
    tagsCtrl.clear();
    setState(() {});
    snack(context, "Question posted.");
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tagsPreview = _parseTags(tagsCtrl.text);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask a question"),
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
            controller: titleCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: "Title",
              hintText: "E.g. How do I study X for the exam?",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: bodyCtrl,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: "Details",
              hintText:
                  "Explain your problem clearly. Add context (course, task, error message, what you tried).",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: tagsCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: "Tags",
              hintText: "E.g. flutter concurrency exam",
              border: OutlineInputBorder(),
            ),
          ),

          if (tagsPreview.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tagsPreview.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _post(state),
            icon: const Icon(Icons.publish_outlined),
            label: const Text("Post question"),
          ),
        ],
      ),
    );
  }
}
