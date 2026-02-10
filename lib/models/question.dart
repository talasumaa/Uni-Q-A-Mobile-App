class Question {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final String authorId;
  final DateTime createdAt;

  int downvotes;
  int upvotes;
  String? acceptedAnswerId;

  Question({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.authorId,
    required this.createdAt,
    this.downvotes = 0,
    this.upvotes = 0,
    this.acceptedAnswerId,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "body": body,
        "tags": tags,
        "authorId": authorId,
        "createdAt": createdAt.toIso8601String(),
        "upvotes": upvotes,
        "downvotes": downvotes,
        "acceptedAnswerId": acceptedAnswerId,
      };

  static Question fromJson(Map<String, dynamic> j) => Question(
        id: j["id"],
        title: j["title"],
        body: j["body"],
        tags: (j["tags"] as List).map((e) => e.toString()).toList(),
        authorId: j["authorId"],
        createdAt: DateTime.parse(j["createdAt"]),
        upvotes: (j["upvotes"] as num?)?.toInt() ?? 0,
        downvotes: (j["downvotes"] as num?)?.toInt() ?? 0,
        acceptedAnswerId: j["acceptedAnswerId"],
      );
}
