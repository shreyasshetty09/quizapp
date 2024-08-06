import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createQuiz() async {
    CollectionReference quizzes = _db.collection('quizzes');

    await quizzes.add({
      'name': 'Sample Quiz',
      'totalMarks': 100,
      'isActive': true,
      'questions': [
        {
          'question': 'What is 2 + 2?',
          'options': ['1', '2', '3', '4'],
          'correctOption': 3,
          'marks': 10
        },
        {
          'question': 'What is the capital of France?',
          'options': ['Berlin', 'London', 'Madrid', 'Paris'],
          'correctOption': 3,
          'marks': 10
        }
      ]
    });
  }
}
