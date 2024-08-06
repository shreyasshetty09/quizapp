import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizParticipationPage extends StatefulWidget {
  final String quizId;
  final String quizLink;

  QuizParticipationPage({required this.quizId, required this.quizLink});

  @override
  _QuizParticipationPageState createState() => _QuizParticipationPageState();
}

class _QuizParticipationPageState extends State<QuizParticipationPage> {
  final List<int?> _selectedOptions = [];
  final List<bool> _lockedOptions = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitted = false;
  bool _alreadyParticipated = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyParticipated();
  }

  Future<void> _checkIfAlreadyParticipated() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot participantSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('participants')
          .doc(user.uid)
          .get();

      if (participantSnapshot.exists) {
        setState(() {
          _alreadyParticipated = true;
        });
        _showAlertDialog(
            'Already Participated', 'You have already attempted this quiz.');
      }
    }
  }

  void _submitQuiz() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? 'Anonymous';
      List<Map<String, dynamic>> attemptedQuestions = [];
      int correctAnswers = 0;

      // Get the quiz data to compare answers
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();
      final questions = quizSnapshot['questions'] as List<dynamic>;

      // Collect all attempted questions and their selected options
      for (int i = 0; i < _selectedOptions.length; i++) {
        bool isCorrect =
            _selectedOptions[i] == questions[i]['correctOptionIndex'];
        if (isCorrect) correctAnswers++;
        attemptedQuestions.add({
          'question': questions[i]['questionText'],
          'selectedOption': _selectedOptions[i],
          'correctOptionIndex': questions[i]['correctOptionIndex'],
          'isCorrect': isCorrect,
        });
      }

      // Store the result in Firestore
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('participants')
          .doc(user.uid)
          .set({
        'email': email,
        'attemptedQuestions': attemptedQuestions,
        'correctAnswers': correctAnswers,
      });

      // Show submission result
      _showAlertDialog('Quiz Submitted Successfully',
          'Thank you for attempting the quiz. Happy Learning!');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Quiz Submitted Successfully' ||
                    title == 'Already Participated') {
                  Navigator.of(context).pop(); // Navigate back to QuizJoinPage
                }
              },
              child: Text('OK'),
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
        title: Text('Participate in Quiz', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _alreadyParticipated
          ? Center(
              child: Text(
                'You have already participated in this quiz.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(widget.quizId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final quiz = snapshot.data!;
                final questions = quiz['questions'] as List<dynamic>;

                // Initialize the selected options and locked options list
                if (_selectedOptions.length != questions.length) {
                  _selectedOptions.clear();
                  _selectedOptions
                      .addAll(List<int?>.filled(questions.length, null));
                  _lockedOptions.clear();
                  _lockedOptions
                      .addAll(List<bool>.filled(questions.length, false));
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final question = questions[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 5,
                              color: Colors.teal.shade100.withOpacity(0.5),
                              child: ListTile(
                                title: Text(
                                  question['questionText'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...List.generate(4, (i) {
                                      return RadioListTile<int>(
                                        title: Text(
                                          'Option ${i + 1}: ${question['options'][i]}',
                                          style: TextStyle(
                                              color: Colors.teal.shade900),
                                        ),
                                        value: i,
                                        groupValue: _selectedOptions[index],
                                        onChanged: _lockedOptions[index]
                                            ? null
                                            : (int? value) {
                                                setState(() {
                                                  _selectedOptions[index] =
                                                      value;
                                                });
                                              },
                                      );
                                    }),
                                    SizedBox(height: 8),
                                    if (_lockedOptions[index])
                                      AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: Icon(
                                          _selectedOptions[index] ==
                                                  question['correctOptionIndex']
                                              ? Icons.check
                                              : Icons.close,
                                          color: _selectedOptions[index] ==
                                                  question['correctOptionIndex']
                                              ? Colors.green
                                              : Colors.red,
                                          key: ValueKey<int>(
                                              _selectedOptions[index] ?? -1),
                                        ),
                                      ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _lockedOptions[index]
                                          ? null
                                          : () {
                                              setState(() {
                                                _lockedOptions[index] = true;
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade800,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Lock and Check',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _isSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    _isSubmitted = true;
                                  });
                                  _submitQuiz();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Submit',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
