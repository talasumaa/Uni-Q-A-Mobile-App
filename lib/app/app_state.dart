import 'dart:collection';
import 'package:flutter/material.dart';

import '../data/qna_repository.dart';
import '../models/app_user.dart';
import '../models/question.dart';
import '../models/answer.dart';

class AppState extends ChangeNotifier {
  final QnaRepository repo;

  bool loaded = false;

  List<AppUser> _users = [];
  List<Question> _questions = [];
  List<Answer> _answers = [];
  final Map<String, int> _votes = {};

  String? _currentUserId;
  AppState({required this.repo});

  UnmodifiableListView<AppUser> get users => UnmodifiableListView(_users);
  UnmodifiableListView<Question> get questions =>
      UnmodifiableListView(_questions);
  UnmodifiableListView<Answer> get answers => UnmodifiableListView(_answers);

  bool get isLoggedIn => _currentUserId != null;

  String? get currentUserIdOrNull => _currentUserId;
  String get currentUserId {
    if (_currentUserId == null) {
      throw StateError("Not logged in");
    }
    return _currentUserId!;
  }

  AppUser get currentUser {
    final id = currentUserId;
    return _users.firstWhere((u) => u.id == id);
  }

  Future<void> init() async {
    final snapshot = await repo.load();

    _users = snapshot.users;
    _questions = snapshot.questions;
    _answers = snapshot.answers;

    _votes
      ..clear()
      ..addAll(snapshot.votes);

    _currentUserId = snapshot.currentUserId;
    if (_users.isEmpty) {
      _seedDemoUsersOnly();
      _currentUserId = null;

      await repo.save(
        users: _users,
        questions: _questions,
        answers: _answers,
        votes: _votes,
        currentUserId: _currentUserId,
      );
    } else {
      if (_currentUserId != null &&
          !_users.any((u) => u.id == _currentUserId)) {
        _currentUserId = null;
        await repo.save(
          users: _users,
          questions: _questions,
          answers: _answers,
          votes: _votes,
          currentUserId: _currentUserId,
        );
      }
    }

    loaded = true;
    notifyListeners();
  }

  Future<void> login(String userId) async {
    if (!_users.any((u) => u.id == userId)) return;
    _currentUserId = userId;
    await _persist();
  }

  Future<void> logout() async {
    _currentUserId = null;
    await _persist();
  }
  Future<void> updateCurrentUserProfile({
    required String displayName,
    required String program,
    required String semester,
    required String bio,
  }) async {
    final uid = currentUserId;
    final idx = _users.indexWhere((u) => u.id == uid);
    if (idx < 0) return;

    final dn = displayName.trim();
    if (dn.isEmpty) return;

    _users[idx] = AppUser(
      id: _users[idx].id,
      displayName: dn,
      program: program.trim().isEmpty ? null : program.trim(),
      semester: semester.trim().isEmpty ? null : semester.trim(),
      bio: bio.trim().isEmpty ? null : bio.trim(),
    );

    await _persist();
  }

  AppUser userById(String id) => _users.firstWhere((u) => u.id == id);

  List<Question> questionsByUser(String uid) =>
      _questions.where((q) => q.authorId == uid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Answer> answersByUser(String uid) =>
      _answers.where((a) => a.authorId == uid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Answer> answersForQuestion(String qid) {
    final list = _answers.where((a) => a.questionId == qid).toList();

    list.sort((a, b) {
      final q = _questions.firstWhere((qq) => qq.id == qid);

      final aAcc = (q.acceptedAnswerId == a.id) ? 1 : 0;
      final bAcc = (q.acceptedAnswerId == b.id) ? 1 : 0;
      if (aAcc != bAcc) return bAcc.compareTo(aAcc);

      final uv = b.upvotes.compareTo(a.upvotes);
      if (uv != 0) return uv;

      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  int acceptedAnswersCount(String uid) {
    int c = 0;
    for (final q in _questions) {
      final acc = q.acceptedAnswerId;
      if (acc == null) continue;
      final a = _answers.where((x) => x.id == acc).cast<Answer?>().firstOrNull;
      if (a != null && a.authorId == uid) c++;
    }
    return c;
  }

  int reputation(String uid) {
    final userAnswers = answersByUser(uid);
    final scoreVotes = userAnswers.fold<int>(
      0,
      (sum, a) => sum + (a.upvotes - a.downvotes),
    );
    final acc = acceptedAnswersCount(uid);
    return scoreVotes + 5 * acc;
  }

  List<String> topTagsForUser(String uid, {int max = 6}) {
    final map = <String, int>{};
    final userAnswers = answersByUser(uid);

    for (final a in userAnswers) {
      final q = _questions
          .where((q) => q.id == a.questionId)
          .cast<Question?>()
          .firstOrNull;
      if (q == null) continue;

      final weight = (a.upvotes - a.downvotes).clamp(0, 50) + 1;
      for (final t in q.tags) {
        map[t] = (map[t] ?? 0) + weight;
      }
    }

    final sorted = map.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return sorted.take(max).map((e) => e.key).toList();
  }

  int voteForQuestion(String qid) {
    final uid = _currentUserId;
    if (uid == null) return 0;
    return _votes[_voteKeyQuestion(qid, uid)] ?? 0;
  }

  int voteForAnswer(String aid) {
    final uid = _currentUserId;
    if (uid == null) return 0;
    return _votes[_voteKeyAnswer(aid, uid)] ?? 0;
  }

  Future<void> voteQuestion(String qid, int newVote) async {
    if (!isLoggedIn) return;
    if (newVote != 1 && newVote != -1) return;

    final q = _questions.firstWhere((q) => q.id == qid);
    final uid = currentUserId;    final key = _voteKeyQuestion(qid, uid);
    final prev = _votes[key] ?? 0;

    if (prev == newVote) {
      if (newVote == 1) q.upvotes = _decNonNegative(q.upvotes);
      if (newVote == -1) q.downvotes = _decNonNegative(q.downvotes);
      _votes[key] = 0;
    } else {
      if (prev == 1) q.upvotes = _decNonNegative(q.upvotes);
      if (prev == -1) q.downvotes = _decNonNegative(q.downvotes);

      if (newVote == 1) q.upvotes += 1;
      if (newVote == -1) q.downvotes += 1;

      _votes[key] = newVote;
    }

    await _persist();
  }

  Future<void> voteAnswer(String aid, int newVote) async {
    if (!isLoggedIn) return;
    if (newVote != 1 && newVote != -1) return;

    final a = _answers.firstWhere((a) => a.id == aid);
    final uid = currentUserId;    final key = _voteKeyAnswer(aid, uid);
    final prev = _votes[key] ?? 0;

    if (prev == newVote) {
      if (newVote == 1) a.upvotes = _decNonNegative(a.upvotes);
      if (newVote == -1) a.downvotes = _decNonNegative(a.downvotes);
      _votes[key] = 0;
    } else {
      if (prev == 1) a.upvotes = _decNonNegative(a.upvotes);
      if (prev == -1) a.downvotes = _decNonNegative(a.downvotes);

      if (newVote == 1) a.upvotes += 1;
      if (newVote == -1) a.downvotes += 1;

      _votes[key] = newVote;
    }

    await _persist();
  }

  bool canCurrentUserAccept(Question q) {
    final uid = _currentUserId;
    if (uid == null) return false;
    return q.authorId == uid;
  }

  Future<void> acceptAnswer(String qid, String aid) async {
    if (!isLoggedIn) return;
    final q = _questions.firstWhere((q) => q.id == qid);
    final uid = _currentUserId;
    if (uid == null) return;
    if (q.authorId != uid) return;

    q.acceptedAnswerId = (q.acceptedAnswerId == aid) ? null : aid;
    await _persist();
  }

  Future<void> addQuestion({
    required String title,
    required String body,
    required List<String> tags,
  }) async {
    if (!isLoggedIn) return;

    final q = Question(
      id: _id("q"),
      title: title.trim(),
      body: body.trim(),
      tags: tags,
      authorId: currentUserId,
      createdAt: DateTime.now(),
      upvotes: 0,
      downvotes: 0,
      acceptedAnswerId: null,
    );

    _questions.insert(0, q);
    await _persist();
  }

  Future<void> addAnswer({
    required String questionId,
    required String body,
  }) async {
    if (!isLoggedIn) return;

    final a = Answer(
      id: _id("a"),
      questionId: questionId,
      body: body.trim(),
      authorId: currentUserId,
      createdAt: DateTime.now(),
      upvotes: 0,
      downvotes: 0,
    );

    _answers.insert(0, a);
    await _persist();
  }

  Future<void> resetDemo() async {
    await repo.reset();
    _users = [];
    _questions = [];
    _answers = [];
    _votes.clear();
    _currentUserId = null;
    loaded = false;
    notifyListeners();
    await init();
  }

  void _seedDemoUsersOnly() {
    final u1 = AppUser(
      id: _id("u"),
      displayName: "You",
      program: "Computer Science",
      semester: "2nd semester",
      bio: "Demo user for development and testing.",
    );
    final u2 = AppUser(
      id: _id("u"),
      displayName: "User 2",
      program: "Computer Science",
      semester: "3rd semester",
      bio: "Another demo user.",
    );

    _users.addAll([u1, u2]);
    _questions.clear();
    _answers.clear();
    _votes.clear();
  }

  Future<void> _persist() async {
    await repo.save(
      users: _users,
      questions: _questions,
      answers: _answers,
      votes: _votes,
      currentUserId: _currentUserId,    );
    notifyListeners();
  }

  int _decNonNegative(int v) => (v <= 0) ? 0 : v - 1;

  String _id(String prefix) =>
      "${prefix}_${DateTime.now().microsecondsSinceEpoch}";

  String _voteKeyQuestion(String qid, String uid) => "q:$qid:u:$uid";
  String _voteKeyAnswer(String aid, String uid) => "a:$aid:u:$uid";
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.child,
    required AppState notifier,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, "AppStateScope not found");
    return scope!.notifier!;
  }
}

extension _FirstOrNullX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
