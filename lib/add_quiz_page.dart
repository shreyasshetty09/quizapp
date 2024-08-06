import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuizPage extends StatefulWidget {
  @override
  _AddQuizPageState createState() => _AddQuizPageState();
}

class _AddQuizPageState extends State<AddQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();
  final List<Question> _questions = [];

  void _addQuestion() {
    setState(() {
      _questions.add(Question());
    });
  }

  void _saveQuiz() async {
    if (_formKey.currentState?.validate() ?? false) {
      final quizData = {
        'title': _quizTitleController.text,
        'questions': _questions.map((q) => q.toMap()).toList(),
      };
      await FirebaseFirestore.instance.collection('quizzes').add(quizData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Quiz', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _quizTitleController,
                  decoration: InputDecoration(
                    labelText: 'Quiz Title',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal.shade100.withOpacity(0.5),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ..._questions.map((q) => QuestionWidget(question: q)).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Add Question',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Question {
  String questionText = '';
  List<String> options = ['', '', '', ''];
  int correctOptionIndex = 0;
  int marks = 0;

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'marks': marks,
    };
  }
}

class QuestionWidget extends StatefulWidget {
  final Question question;
  QuestionWidget({required this.question});

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.shade100.withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(0),
        elevation: 1,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  widget.question.questionText.isEmpty
                      ? 'New Question'
                      : widget.question.questionText,
                  style: TextStyle(color: Colors.teal.shade900),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Question Text',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal.shade100.withOpacity(0.5),
                    ),
                    onChanged: (value) {
                      setState(() {
                        widget.question.questionText = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  ...List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.teal.shade100.withOpacity(0.5),
                        ),
                        onChanged: (value) {
                          setState(() {
                            widget.question.options[index] = value;
                          });
                        },
                      ),
                    );
                  }),
                  DropdownButtonFormField<int>(
                    value: widget.question.correctOptionIndex,
                    items: List.generate(4, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('Option ${index + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        widget.question.correctOptionIndex = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Correct Option',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal.shade100.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Marks',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.teal.shade100.withOpacity(0.5),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        widget.question.marks = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
