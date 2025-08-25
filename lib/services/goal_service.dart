import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser?.uid ?? '';
  static String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Stream<Map<String, bool>> todayGoalsStream() {
    return _firestore.collection('user_goals').doc(_uid).snapshots().map((doc) {
      final data = doc.data()?[_todayKey] as Map<String, dynamic>?;
      return {
        'journaling': data?['journaling'] == true,
        'meditation': data?['meditation'] == true,
        'sleep': data?['sleep'] == true,
      };
    });
  }

  static Future<void> setGoalCompleted(String goal) async {
    final docRef = _firestore.collection('user_goals').doc(_uid);
    await docRef.set({
      _todayKey: {goal: true}
    }, SetOptions(merge: true));
  }
}
