import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'quiz_participation_page.dart';

class QuizJoinPage extends StatefulWidget {
  @override
  _QuizJoinPageState createState() => _QuizJoinPageState();
}

class _QuizJoinPageState extends State<QuizJoinPage> {
  final _quizLinkController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _joinQuiz() async {
    final quizLink = _quizLinkController.text;
    if (quizLink.isEmpty) {
      _showAlertDialog('Error', 'Please enter a quiz link.');
      return;
    }
    final quizId = quizLink.split('/').last;
    if (quizId.isEmpty) {
      _showAlertDialog('Error', 'Invalid quiz link.');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      _showAlertDialog('Error', 'You must be logged in to join a quiz.');
      return;
    }

    final email = user.email;
    if (email == null) {
      _showAlertDialog('Error', 'No email found for the logged-in user.');
      return;
    }

    try {
      final participantDoc = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('participants')
          .doc(email)
          .get();

      if (participantDoc.exists) {
        _showAlertDialog('Error', 'You have already joined this quiz.');
      } else {
        await _firestore
            .collection('quizzes')
            .doc(quizId)
            .collection('participants')
            .doc(email)
            .set({'joinedAt': Timestamp.now(), 'email': email});

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizParticipationPage(quizId: quizId, quizLink: quizLink),
          ),
        ).then((_) {
          _showAlertDialog('Success', 'You have successfully joined the quiz.');
        });
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to join the quiz. Please try again.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: Colors.teal.shade800)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.teal.shade800)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Quiz'),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _quizLinkController,
              decoration: InputDecoration(
                labelText: 'Quiz Link',
                labelStyle: TextStyle(color: Colors.teal.shade800),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal.shade800),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Join Quiz',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
