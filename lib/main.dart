import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('projects');
  await Hive.openBox('tasks');
  await Hive.openBox('entries');
  runApp(const TimeTrackerApp());
}

class TimeTrackerApp extends StatelessWidget {
  const TimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC1E3),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFD7B2FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        // Removed fontFamily as it might not be available
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFC1E3),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== Home Screen ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final projectsBox = Hive.box('projects');
  final tasksBox = Hive.box('tasks');
  final entriesBox = Hive.box('entries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker 💖'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFFC1E3),
              ),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Projects'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tasks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: entriesBox.listenable(),
        builder: (context, Box entries, _) {
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'No time entries yet 💜',
                style: TextStyle(fontSize: 18, color: Color(0xFFD7B2FF)),
              ),
            );
          }

          // Group entries by project
          Map<String, List<Map>> groupedEntries = {};
          for (var key in entries.keys) {
            var entry = entries.get(key);
            String project = entry['project'] ?? 'No Project';
            groupedEntries[project] ??= [];
            groupedEntries[project]!.add({...Map<String, dynamic>.from(entry), 'key': key});
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: groupedEntries.entries.map((group) {
              return ExpansionTile(
                textColor: Colors.white,
                collapsedTextColor: Colors.pinkAccent,
                backgroundColor: const Color(0xFFD7B2FF).withOpacity(0.2),
                collapsedBackgroundColor: const Color(0xFFFFC1E3).withOpacity(0.1),
                title: Text(
                  group.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: group.value.map((entry) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    color: const Color(0xFFFFE6F0),
                    child: ListTile(
                      title: Text(
                        '${entry['task'] ?? 'No Task'} - ${entry['time']}h',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${entry['notes'] ?? ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.pinkAccent),
                        onPressed: () {
                          entriesBox.delete(entry['key']);
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD7B2FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
        },
      ),
    );
  }
}

// ==================== Add Time Entry ====================
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProject;
  String? selectedTask;
  double? time;
  String? notes;
  DateTime date = DateTime.now();

  final projectsBox = Hive.box('projects');
  final tasksBox = Hive.box('tasks');
  final entriesBox = Hive.box('entries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total time (hours)',
                  filled: true,
                  fillColor: Color(0xFFFFF0F5),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter time';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => time = double.tryParse(value ?? '0'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Project',
                  filled: true,
                  fillColor: Color(0xFFFFF0F5),
                  border: OutlineInputBorder(),
                ),
                value: selectedProject,
                items: projectsBox.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('No projects'))]
                    : projectsBox.values.toList().map<DropdownMenuItem<String>>((project) {
                        return DropdownMenuItem(
                          value: project.toString(),
                          child: Text(project.toString()),
                        );
                      }).toList(),
                onChanged: (val) => setState(() => selectedProject = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Task',
                  filled: true,
                  fillColor: Color(0xFFFFF0F5),
                  border: OutlineInputBorder(),
                ),
                value: selectedTask,
                items: tasksBox.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('No tasks'))]
                    : tasksBox.values.toList().map<DropdownMenuItem<String>>((task) {
                        return DropdownMenuItem(
                          value: task.toString(),
                          child: Text(task.toString()),
                        );
                      }).toList(),
                onChanged: (val) => setState(() => selectedTask = val),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  filled: true,
                  fillColor: Color(0xFFFFF0F5),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => notes = value,
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: const Color(0xFFFFF0F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: Text('Date: ${date.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != date) {
                    setState(() => date = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD7B2FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Entry', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    entriesBox.add({
                      'time': time,
                      'project': selectedProject,
                      'task': selectedTask,
                      'notes': notes,
                      'date': date.toIso8601String(),
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Project Management ====================
class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final projectsBox = Hive.box('projects');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: ValueListenableBuilder(
        valueListenable: projectsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) return const Center(child: Text('No projects 💖'));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, index) {
              final key = box.keyAt(index);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: const Color(0xFFFFE6F0),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(box.get(key).toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.pinkAccent),
                    onPressed: () {
                      box.delete(key);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD7B2FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddProjectDialog(),
      ),
    );
  }

  void _showAddProjectDialog() {
    String projectName = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Project'),
        content: TextField(
          autofocus: true,
          onChanged: (val) => projectName = val,
          decoration: const InputDecoration(labelText: 'Project Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD7B2FF)),
            onPressed: () {
              if (projectName.isNotEmpty) {
                projectsBox.add(projectName);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ==================== Task Management ====================
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final tasksBox = Hive.box('tasks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) return const Center(child: Text('No tasks 💜'));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, index) {
              final key = box.keyAt(index);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: const Color(0xFFFFE6F0),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text(box.get(key).toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.pinkAccent),
                    onPressed: () {
                      box.delete(key);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD7B2FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTaskDialog(),
      ),
    );
  }

  void _showAddTaskDialog() {
    String taskName = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          autofocus: true,
          onChanged: (val) => taskName = val,
          decoration: const InputDecoration(labelText: 'Task Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD7B2FF)),
            onPressed: () {
              if (taskName.isNotEmpty) {
                tasksBox.add(taskName);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}