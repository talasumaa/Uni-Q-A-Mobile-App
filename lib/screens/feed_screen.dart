import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../screens/question_detail_screen.dart';
import '../widgets/question_card.dart';
import '../models/feed_sort.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback? onTapAsk;

  const FeedScreen({super.key, this.onTapAsk});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String query = "";
  FeedSort sort = FeedSort.newest;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sort",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...FeedSort.values.map((s) {
                  final selected = s == sort;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(s.icon),
                    title: Text(s.label),
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: () {
                      setState(() => sort = s);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final ql = query.trim().toLowerCase();
    final filtered = state.questions.where((q) {
      if (ql.isEmpty) return true;
      return q.title.toLowerCase().contains(ql) ||
          q.body.toLowerCase().contains(ql) ||
          q.tags.any((t) => t.toLowerCase().contains(ql));
    }).toList();

    filtered.sort((a, b) {
      switch (sort) {
        case FeedSort.newest:
          return b.createdAt.compareTo(a.createdAt);
        case FeedSort.top:
          final sa = a.upvotes - a.downvotes;
          final sb = b.upvotes - b.downvotes;
          return sb.compareTo(sa);
        case FeedSort.unanswered:
          final aAns = state.answersForQuestion(a.id).length;
          final bAns = state.answersForQuestion(b.id).length;
          if (aAns == 0 && bAns > 0) return -1;
          if (bAns == 0 && aAns > 0) return 1;
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Ask a question",
        onPressed: widget.onTapAsk,
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text("Uni Q&A"),
            actions: [
              IconButton(
                tooltip: "Info",
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const _InfoDialog(),
                ),
                icon: const Icon(Icons.info_outline),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => query = v),
                        decoration: InputDecoration(
                          hintText: "Search title, tag, content...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Tooltip(
                      message: "Sort: ${sort.label}",
                      child: IconButton.filledTonal(
                        onPressed: _openSortSheet,
                        icon: Icon(sort.icon),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final q = filtered[i];
                final ansCount = state.answersForQuestion(q.id).length;

                return QuestionCard(
                  q: q,
                  answerCount: ansCount,
                  hasAccepted: q.acceptedAnswerId != null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionDetailScreen(questionId: q.id),
                    ),
                  ),
                  onUpvote: () => state.voteQuestion(q.id, 1),
                  onDownvote: () => state.voteQuestion(q.id, -1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  const _InfoDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("What is this?"),
      content: const Text(
        "A university Q&A in a StackOverflow-style format:\n\n"
        "• Students ask questions\n"
        "• Others answer\n"
        "• Upvotes surface the best content\n"
        "• One answer can be marked as 'accepted'\n",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
