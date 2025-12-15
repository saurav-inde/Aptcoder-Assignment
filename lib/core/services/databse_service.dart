import 'package:aptcoder/core/models/course.dart';
import 'package:aptcoder/core/models/lesson.dart';
import 'package:aptcoder/core/models/progress.dart';
import 'package:aptcoder/core/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- COLLECTIONS REFERENCE CONSTANTS ---
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String lessonsSubCollection = 'lessons';
  static const String progressCollection = 'progress';

  // ===================================================
  // I. USER & AUTH-RELATED METHODS
  // ===================================================

  // Creates or updates a user document (Used during Google Auth Sign-in)
  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    final userRef = _db.collection(usersCollection).doc(uid);
    // Use set with merge: true to avoid overwriting existing role/data
    await userRef.set(userData, SetOptions(merge: true));
  }

  // ===================================================
  // USER PROFILE METHODS
  // ===================================================

  // Fetches a User Model to check the 'role'
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(
    String uid, {
    String? educationLevel,
    String? fieldOfStudy,
    String? learningGoal,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};

    if (educationLevel != null) data['educationLevel'] = educationLevel;
    if (fieldOfStudy != null) data['fieldOfStudy'] = fieldOfStudy;
    if (learningGoal != null) data['learningGoal'] = learningGoal;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    await _db.collection(usersCollection).doc(uid).update(data);
  }

  Future<void> enrollUserInCourse({
    required String uid,
    required String courseId,
  }) async {
    await _db.collection(usersCollection).doc(uid).update({
      'enrolledCourseIds': FieldValue.arrayUnion([courseId]),
    });
  }
  // ===================================================
  // II. COURSE & LESSON METHODS (Student Dashboard & Admin Portal)
  // ===================================================

  // STUDENT: Get all available courses (Stream is better for real-time dashboards)
  Stream<List<CourseModel>> streamCourses() {
    return _db.collection(coursesCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // STUDENT: Get all lessons for a specific course
  Stream<List<LessonModel>> streamLessons(String courseId) {
    return _db
        .collection(coursesCollection)
        .doc(courseId)
        .collection(lessonsSubCollection)
        .orderBy('sequence') // Use the sequence field for correct ordering
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LessonModel.fromMap(doc.id, courseId, doc.data()))
              .toList();
        });
  }

  // ADMIN: Add a new course
  Future<void> addCourse(Map<String, dynamic> courseData) async {
    await _db.collection(coursesCollection).add(courseData);
  }

  // ADMIN: Add a new lesson to a course
  Future<void> addLesson(
    String courseId,
    Map<String, dynamic> lessonData,
  ) async {
    await _db
        .collection(coursesCollection)
        .doc(courseId)
        .collection(lessonsSubCollection)
        .add(lessonData);
  }

  // ===================================================
  // III. PROGRESS TRACKING METHODS (Student Progress)
  // ===================================================

  // STUDENT: Mark a specific lesson as completed
  Future<void> markLessonCompleted(
    String userId,
    String courseId,
    String lessonId,
  ) async {
    await _getOrCreateProgressDoc(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
      completed: true,
    );
  }

  Future<void> updateMcqProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required int quesSeq,
    required int chosenOption,
  }) async {
    final docRef = await _getOrCreateProgressDoc(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
    );

    await _db.runTransaction((txn) async {
      final snap = await txn.get(docRef);
      final data = snap.data() as Map<String, dynamic>;

      final List mcqList = List.from(data['mcq'] ?? []);

      // Remove old answer if exists
      mcqList.removeWhere((e) => e['ques_seq'] == quesSeq);

      // Add updated answer
      mcqList.add({'ques_seq': quesSeq, 'chosen_option': chosenOption});

      txn.update(docRef, {'mcq': mcqList});
    });
  }

  Future<DocumentReference> _getOrCreateProgressDoc({
    required String userId,
    required String courseId,
    required String lessonId,
    bool? completed,
  }) async {
    final query = await _db
        .collection(progressCollection)
        .where('user_id', isEqualTo: userId)
        .where('lessonId', isEqualTo: lessonId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.reference;
    }

    return _db.collection(progressCollection).add({
      'user_id': userId,
      'courseId': courseId,
      'lessonId': lessonId,
      'completed': completed ?? false,
      'completedAt': FieldValue.serverTimestamp(),
      'mcq': [],
    });
  }

  // STUDENT: Get all completed lessons for a specific course by the user
  Stream<List<ProgressModel>> streamCourseProgress(
    String userId,
    String courseId,
  ) {
    return _db
        .collection(progressCollection)
        .where('user_id', isEqualTo: userId)
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProgressModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
}
