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
        title: const Text('Add Stack'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                minLines: 17,
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
            const SizedBox(height: 6.0),
            ElevatedButton(
              onPressed: () {
                _addStack();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _addStack() {
    String name = _nameController.text;
    String description = _descriptionController.text;
    String csv = _csvController.text;

    List<Map<String, String>> qaList = _parseCsv(csv);

    // Call the method to add the stack with the parsed data
    DatabaseHelper.instance.addStack(name, description, qaList);

    // Navigate back to the previous screen
    Navigator.pop(context, true);
  }

  List<Map<String, String>> _parseCsv(String csv) {
    List<Map<String, String>> qaList = [];

    List<String> lines = csv.split('\n');
    for (String line in lines) {
      List<String> parts = line.split(',');
      if (parts.length == 2) {
        qaList.add({
          'question': parts[0],
          'answer': parts[1],
        });
      }
    }

    return qaList;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _csvController.dispose();
    super.dispose();
  }
}
