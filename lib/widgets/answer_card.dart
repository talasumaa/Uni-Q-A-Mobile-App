import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../utils/time_ago.dart';

class AnswerCard extends StatelessWidget {
  final Question q;
  final Answer a;
  final bool canAccept;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onAccept;

  const AnswerCard({
    super.key,
    required this.q,
    required this.a,
    required this.canAccept,
    required this.onUpvote,
    required this.onDownvote,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final isAccepted = q.acceptedAnswerId == a.id;
    final cs = Theme.of(context).colorScheme;
    final vote = state.voteForAnswer(a.id);
    final authorName = state.userById(a.authorId).displayName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAccepted)
              Row(
                children: [
                  Icon(Icons.verified_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    "Accepted",
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            if (isAccepted) const SizedBox(height: 8),
            Text(a.body),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.arrow_upward, size: 18),
                  label: Text("${a.upvotes}"),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.arrow_downward, size: 18),
                  label: Text("${a.downvotes}"),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "by $authorName • ${timeAgo(a.createdAt)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: onUpvote,
                  icon: Icon(
                    vote == 1
                        ? Icons.arrow_upward
                        : Icons.arrow_upward_outlined,
                  ),
                  tooltip: "Upvote",
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onDownvote,
                  icon: Icon(
                    vote == -1
                        ? Icons.arrow_downward
                        : Icons.arrow_downward_outlined,
                  ),
                  tooltip: "Downvote",
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: canAccept ? onAccept : null,
                  icon: Icon(
                    isAccepted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  tooltip: canAccept
                      ? (isAccepted ? "Unaccept" : "Accept")
                      : "Only the question author can accept",
                ),
              ],
            ),
            if (!canAccept)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Only the question author can accept an answer.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
