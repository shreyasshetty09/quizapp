import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserResponse(String quizId, List<Map<String, dynamic>> responses, int score) async {
    CollectionReference responsesCollection = _db.collection('responses');
    User? user = _auth.currentUser;

    if (user != null) {
      await responsesCollection.add({
        'quizId': quizId,
        'userId': user.uid,
        'userName': user.displayName,
        'userPhone': user.phoneNumber,
        'userEmail': user.email,
        'responses': responses,
        'score': score
      });
    }
  }
}
