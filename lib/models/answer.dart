class Answer {
  final String id;
  final String questionId;
  final String body;
  final String authorId;
  final DateTime createdAt;

  int downvotes;
  int upvotes;

  Answer({
    required this.id,
    required this.questionId,
    required this.body,
    required this.authorId,
    required this.createdAt,
    this.downvotes = 0,
    this.upvotes = 0,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "questionId": questionId,
        "body": body,
        "authorId": authorId,
        "createdAt": createdAt.toIso8601String(),
        "downvotes": downvotes,
        "upvotes": upvotes,
      };

  static Answer fromJson(Map<String, dynamic> j) => Answer(
        id: j["id"],
        questionId: j["questionId"],
        body: j["body"],
        authorId: j["authorId"],
        createdAt: DateTime.parse(j["createdAt"]),
        downvotes: (j["downvotes"] as num?)?.toInt() ?? 0,
        upvotes: (j["upvotes"] as num?)?.toInt() ?? 0,
      );
}
