import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../widgets/stat_tile.dart';
import '../widgets/empty_box.dart';
import '../screens/question_detail_screen.dart';
import '../utils/snack.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onResetDemo;

  const ProfileScreen({super.key, required this.onResetDemo});

  Future<void> _openEditSheet(BuildContext context, AppState state) async {
    final user = state.currentUser;

    final nameCtrl = TextEditingController(text: user.displayName);
    final programCtrl = TextEditingController(text: user.program ?? "");
    final semesterCtrl = TextEditingController(text: user.semester ?? "");
    final bioCtrl = TextEditingController(text: user.bio ?? "");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + viewInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Edit profile",
                    style: Theme.of(ctx)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: programCtrl,
                      decoration: const InputDecoration(
                        labelText: "Degree",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: semesterCtrl,
                      decoration: const InputDecoration(
                        labelText: "Semester",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: bioCtrl,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Bio",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final dn = nameCtrl.text.trim();
                        if (dn.isEmpty) {
                          snack(context, "Name can't be empty.");
                          return;
                        }

                        await state.updateCurrentUserProfile(
                          displayName: nameCtrl.text,
                          program: programCtrl.text,
                          semester: semesterCtrl.text,
                          bio: bioCtrl.text,
                        );

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          snack(context, "Profile saved.");
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    nameCtrl.dispose();
    programCtrl.dispose();
    semesterCtrl.dispose();
    bioCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;

    final myQ = state.questionsByUser(user.id);
    final myA = state.answersByUser(user.id);
    final rep = state.reputation(user.id);
    final accepted = state.acceptedAnswersCount(user.id);
    final topTags = state.topTagsForUser(user.id);

    final subtitle = [
      if ((user.program ?? "").trim().isNotEmpty) user.program!.trim(),
      if ((user.semester ?? "").trim().isNotEmpty) user.semester!.trim(),
    ].join(" • ");

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              child: Text(
                (user.displayName.isNotEmpty ? user.displayName[0] : "?").toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  if (subtitle.trim().isNotEmpty)
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              tooltip: "Edit profile",
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEditSheet(context, state),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if ((user.bio ?? "").trim().isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(user.bio!),
            ),
          ),

        const SizedBox(height: 12),

        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 92,
          ),
          children: [
            StatTile(label: "Reputation", value: "$rep", icon: Icons.stars_outlined),
            StatTile(label: "Accepted", value: "$accepted", icon: Icons.verified_outlined),
            StatTile(label: "Questions", value: "${myQ.length}", icon: Icons.help_outline),
            StatTile(label: "Answers", value: "${myA.length}", icon: Icons.forum_outlined),
          ],
        ),

        const SizedBox(height: 12),
        Text(
          "Top Tags",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        if (topTags.isEmpty)
          const EmptyBox(
            title: "No expertise tags yet.",
            subtitle: "Tags will be derived automatically once you start posting answers.",
            icon: Icons.local_offer_outlined,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topTags.map((t) => Chip(label: Text(t))).toList(),
          ),

        const SizedBox(height: 16),
        Text(
          "Recent Activity",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),

        Text("My questions", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        if (myQ.isEmpty)
          const Text("No questions yet.")
        else
          ...myQ.take(3).map(
                (q) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline),
                  title: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(q.tags.take(3).join(" • ")),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuestionDetailScreen(questionId: q.id)),
                  ),
                ),
              ),

        const SizedBox(height: 10),

        Text("My answers", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        if (myA.isEmpty)
          const Text("No answers yet.")
        else
          ...myA.take(3).map((a) {
            final q = state.questions.firstWhere((q) => q.id == a.questionId);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.forum_outlined),
              title: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(a.body, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuestionDetailScreen(questionId: q.id)),
              ),
            );  
          }),

        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => state.logout(),
          icon: const Icon(Icons.logout),
          label: const Text("Log out"),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: onResetDemo,
          icon: const Icon(Icons.refresh),
          label: const Text("Reset demo data"),
        ),
      ],
    );
  }
}
