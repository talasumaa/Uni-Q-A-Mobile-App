import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../models/question.dart';
import '../utils/time_ago.dart';
import 'mini_chip.dart';

class QuestionCard extends StatelessWidget {
  final Question q;
  final int answerCount;
  final bool hasAccepted;
  final VoidCallback onTap;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const QuestionCard({
    super.key,
    required this.q,
    required this.answerCount,
    required this.hasAccepted,
    required this.onTap,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = AppStateScope.of(context);
    final vote = state.voteForQuestion(q.id);
    final authorName = state.userById(q.authorId).displayName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
          color: cs.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(q.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MiniChip(icon: Icons.arrow_upward, label: "${q.upvotes}"),
                  MiniChip(icon: Icons.arrow_downward, label: "${q.downvotes}"),
                  MiniChip(icon: Icons.forum_outlined, label: "$answerCount"),
                  if (hasAccepted)
                    MiniChip(icon: Icons.verified_outlined, label: "Accepted"),
                  ...q.tags
                      .take(4)
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "by $authorName • ${timeAgo(q.createdAt)}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
