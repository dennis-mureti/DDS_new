import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:flutter/material.dart';

class FeedbackView extends StatelessWidget {
  final TextEditingController _feedbackController = TextEditingController();

  FeedbackView({Key key}) : super(key: key);

  void _submitFeedback(BuildContext context) {
    final feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      print('Feedback submitted: $feedback');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
        ),
      );
      _feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter feedback before submitting.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: kColDDSPrimaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            const Text(
              'Out of Route Feedback',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                fillColor: Colors.grey.shade200, // Light grey background
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none, // Remove border line
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submitFeedback(context),
              style: ElevatedButton.styleFrom(
                primary: kColDDSPrimaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.feedback, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Submit Feedback',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
