import 'package:flutter/material.dart';
import 'data.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _csvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Stack'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextFormField(
                controller: _csvController,
                minLines: 7,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: '',
                  hintText: 'Enter questions and answers separated by commas',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'Monospace', fontSize: 12.0),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addNewStack();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewStack() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String csv = _csvController.text.trim();

    // Split CSV into questions and answers
    List<String> parts = csv.split(',');
    List<Map<String, String>> qaList = [];
    for (int i = 0; i < parts.length; i += 2) {
      if (i + 1 < parts.length) {
        qaList.add({'question': parts[i], 'answer': parts[i + 1]});
      }
    }
    await DatabaseHelper.instance.addStack(name, description, qaList);

    // Clear text fields after submission
    _nameController.clear();
    _descriptionController.clear();
    _csvController.clear();

    // Show a snackbar to indicate successful submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stack added successfully!'),
      ),
    );
  }
}
