import 'package:flutter/material.dart';

enum FeedSort { newest, top, unanswered }

extension FeedSortX on FeedSort {
  String get label => switch (this) {
        FeedSort.newest => "Newest",
        FeedSort.top => "Top",
        FeedSort.unanswered => "Unanswered",
      };

  IconData get icon => switch (this) {
        FeedSort.newest => Icons.schedule,
        FeedSort.top => Icons.trending_up,
        FeedSort.unanswered => Icons.help_outline,
      };
}
