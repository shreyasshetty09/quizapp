import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class QuizDetailPage extends StatelessWidget {
  final String quizId;
  QuizDetailPage({required this.quizId});

  @override
  Widget build(BuildContext context) {
    final quizLink =
        "https://example.com/quiz/$quizId"; // Replace with actual URL generation logic

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Details'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('quizzes').doc(quizId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final quiz = snapshot.data!;
          final questions = quiz['questions'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildQuizLinkTile(context, quizLink),
                SizedBox(height: 20),
                _buildQuestionsSection(questions),
                SizedBox(height: 20),
                _buildParticipantsSection(context, quizId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizLinkTile(BuildContext context, String quizLink) {
    return Card(
      elevation: 5,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          'Quiz Link',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(quizLink),
        trailing: IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: quizLink));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quiz link copied to clipboard')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionsSection(List<dynamic> questions) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            ...questions.map((question) {
              final options = question['options'] as List<dynamic>? ?? [];
              final correctOptionIndex = question['correctOptionIndex'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Card(
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      question['questionText'] ?? 'No question text',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(4, (index) {
                            return Text(
                              'Option ${index + 1}: ${options.length > index ? options[index] : 'No option'}',
                              style: TextStyle(fontSize: 16),
                            );
                          })
                            ..add(
                              Text(
                                'Correct Answer: Option ${correctOptionIndex != null ? correctOptionIndex + 1 : 'No correct option'}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, String quizId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('participants')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final participants = snapshot.data!.docs;

        return Card(
          elevation: 5,
          child: ExpansionTile(
            title: Text(
              'Participants',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            children: participants.map((participant) {
              final data = participant.data() as Map<String, dynamic>? ?? {};
              final email = data['email'] ?? 'No email';
              final correctAnswers = data['correctAnswers'] ?? 0;
              final attemptedQuestions =
                  data['attemptedQuestions'] as List<dynamic>? ?? [];

              return ListTile(
                title: Text(
                  '$email - Correct Answers: $correctAnswers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attemptedQuestions.map((attempt) {
                    final correctOptionIndex = attempt['correctOptionIndex'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Question: ${attempt['question'] ?? 'No question'} \nSelected Option: Option ${attempt['selectedOption'] + 1} \nCorrect Option: Option ${correctOptionIndex != null ? correctOptionIndex + 1 : 'No correct option'}',
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
