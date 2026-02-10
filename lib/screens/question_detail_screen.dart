import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../widgets/answer_card.dart';
import '../widgets/empty_box.dart';
import '../utils/time_ago.dart';
import '../screens/add_answer_screen.dart';
import '../widgets/mini_chip.dart';

class QuestionDetailScreen extends StatelessWidget {
  final String questionId;

  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final q = state.questions.firstWhere((q) => q.id == questionId);
    final ans = state.answersForQuestion(questionId);
    final canAccept = state.canCurrentUserAccept(q);

    final authorName = state.userById(q.authorId).displayName;

    return Scaffold(
      appBar: AppBar(title: const Text("Question")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddAnswerScreen(questionId: questionId)),
        ),
        icon: const Icon(Icons.reply_outlined),
        label: const Text("Answer"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(q.body),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MiniChip(icon: Icons.arrow_upward, label: "${q.upvotes}"),
                      MiniChip(icon: Icons.arrow_downward, label: "${q.downvotes}"),
                      MiniChip(icon: Icons.forum_outlined, label: "${ans.length}"),
                      if (q.acceptedAnswerId != null)
                        const MiniChip(icon: Icons.verified_outlined, label: "Accepted"),
                      ...q.tags.map(
                        (t) => Chip(
                          label: Text(t),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "by $authorName • ${timeAgo(q.createdAt)}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: () => state.voteQuestion(q.id, 1),
                        icon: const Icon(Icons.arrow_upward),
                        tooltip: "Upvote",
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => state.voteQuestion(q.id, -1),
                        icon: const Icon(Icons.arrow_downward),
                        tooltip: "Downvote",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                "Answers",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text("${ans.length}"),
            ],
          ),
          const SizedBox(height: 10),
          if (ans.isEmpty)
            const EmptyBox(
              title: "No answers yet",
              subtitle: "Be the first to help",
              icon: Icons.forum_outlined,
            ),
          ...ans.map(
            (a) => AnswerCard(
              q: q,
              a: a,
              canAccept: canAccept,
              onUpvote: () => state.voteAnswer(a.id, 1),
              onDownvote: () => state.voteAnswer(a.id, -1),
              onAccept: () => state.acceptAnswer(q.id, a.id),
            ),
          ),
        ],
      ),
    );
  }
}
