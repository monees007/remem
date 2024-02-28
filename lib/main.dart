import 'package:flutter/material.dart';
import 'package:learner/add.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learner/card.dart';
import 'data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stack List',
      theme: ThemeData.light(), // Default theme (light mode)
      darkTheme: ThemeData.dark(), // Dark theme
      home: const StackList(),
    );
  }
}

class StackList extends StatefulWidget {
  const StackList({super.key});

  @override
  _StackListState createState() => _StackListState();
}

class _StackListState extends State<StackList> {
  late Future<List<Map<String, dynamic>>> _stacksFuture;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadStacks();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !(prefs.getBool('isDarkMode') ?? false);
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  Future<void> _loadStacks() async {
    setState(() {
      // DatabaseHelper.instance.addSampleData();
      _stacksFuture = DatabaseHelper.instance.getAllStacks();
    });
  }

  Future<void> _refreshStacks() async {
    await _loadStacks();
  }

  // Method to show the bottom sheet with edit and delete options
  void _showOptions(BuildContext context, Map<String, dynamic> stack) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showEditDialog(stack); // Navigate to the edit page
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _confirmDelete(stack); // Show the delete confirmation dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> stack) {
    String title = stack['title'];
    String description = stack['description'];

    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController descriptionController =
        TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Stack'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newTitle = titleController.text;
                String newDescription = descriptionController.text;
                _updateStack(stack['id'], newTitle, newDescription);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

// Method to update the stack with new title and description
  void _updateStack(int stackId, String newTitle, String newDescription) {
    // Implement stack update logic here
    // After updating, you may want to refresh the stack list
    DatabaseHelper.instance.updateStack(stackId, newTitle, newDescription);
    _loadStacks();
  }

  // Method to show the delete confirmation dialog
  void _confirmDelete(Map<String, dynamic> stack) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this stack?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                DatabaseHelper.instance.deleteStack(stack['id']);
                _loadStacks(); // Delete the stack
              },
              child: const Text('Delete'),
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
        title: const Text('Stack List'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStacks,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _stacksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final stacks = snapshot.data!;
              return ListView.builder(
                itemCount: stacks.length,
                itemBuilder: (context, index) {
                  final stack = stacks[index];
                  return ListTile(
                    title: Text(stack['title']),
                    subtitle: Text(stack['description']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CardView(
                                title: stack['title'], stackId: stack['id'])),
                      );
                    },
                    onLongPress: () {
                      // Show options
                      _showOptions(context, stack);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPage()),
          ).then((value) {
            if (value == true) {
              _loadStacks();
            }
          });
        },
      ),
    );
  }
}
