class AppUser {
  final String id;
  final String displayName;
  final String? program;
  final String? semester;
  final String? bio;

  const AppUser({
    required this.id,
    required this.displayName,
    this.program,
    this.semester,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "displayName": displayName,
        "program": program,
        "semester": semester,
        "bio": bio,
      };

  static AppUser fromJson(Map<String, dynamic> j) => AppUser(
        id: j["id"],
        displayName: j["displayName"],
        program: j["program"],
        semester: j["semester"],
        bio: j["bio"],
      );
}
