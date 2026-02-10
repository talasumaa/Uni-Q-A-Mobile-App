import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/question.dart';
import '../models/answer.dart';

class QnaSnapshot {
  final List<AppUser> users;
  final List<Question> questions;
  final List<Answer> answers;
  final Map<String, int> votes;
  final String? currentUserId;

  QnaSnapshot({
    required this.users,
    required this.questions,
    required this.answers,
    required this.votes,
    required this.currentUserId,
  });
}

class QnaRepository {
  static const _keyUsers = "qna_users_v2";
  static const _keyQuestions = "qna_questions_v2";
  static const _keyAnswers = "qna_answers_v2";
  static const _keyVotes = "qna_votes_v2";
  static const _keyCurrentUserId = "qna_current_user_id_v2";

  Future<QnaSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();

    final uStr = prefs.getString(_keyUsers);
    final qStr = prefs.getString(_keyQuestions);
    final aStr = prefs.getString(_keyAnswers);
    final vStr = prefs.getString(_keyVotes);
    final currentUserId = prefs.getString(_keyCurrentUserId); 

    List<AppUser> users = [];
    List<Question> questions = [];
    List<Answer> answers = [];
    Map<String, int> votes = {};

    if (uStr != null && uStr.isNotEmpty) {
      final decoded = jsonDecode(uStr) as List;
      users = decoded
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (qStr != null && qStr.isNotEmpty) {
      final decoded = jsonDecode(qStr) as List;
      questions = decoded
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (aStr != null && aStr.isNotEmpty) {
      final decoded = jsonDecode(aStr) as List;
      answers = decoded
          .map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (vStr != null && vStr.isNotEmpty) {
      final decoded = jsonDecode(vStr) as Map<String, dynamic>;
      votes = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return QnaSnapshot(
      users: users,
      questions: questions,
      answers: answers,
      votes: votes,
      currentUserId: currentUserId,
    );
  }

  Future<void> save({
    required List<AppUser> users,
    required List<Question> questions,
    required List<Answer> answers,
    required Map<String, int> votes,
    required String? currentUserId,  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyUsers,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
    await prefs.setString(
      _keyQuestions,
      jsonEncode(questions.map((q) => q.toJson()).toList()),
    );
    await prefs.setString(
      _keyAnswers,
      jsonEncode(answers.map((a) => a.toJson()).toList()),
    );
    await prefs.setString(_keyVotes, jsonEncode(votes));
    if (currentUserId == null) {
      await prefs.remove(_keyCurrentUserId);
    } else {
      await prefs.setString(_keyCurrentUserId, currentUserId);
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsers);
    await prefs.remove(_keyQuestions);
    await prefs.remove(_keyAnswers);
    await prefs.remove(_keyVotes);
    await prefs.remove(_keyCurrentUserId);
  }
}
