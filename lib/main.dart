import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

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
      title: "Time Tracker",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1565C0),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

////////////////////////////////////////////////////////////
/// HOME SCREEN
////////////////////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entriesBox = Hive.box('entries');

    return Scaffold(
      appBar: AppBar(title: const Text("Time Tracker")),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0D47A1)),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.folder, color: Color(0xFF0D47A1)),
              title: const Text("Projects"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.task, color: Color(0xFF0D47A1)),
              title: const Text("Tasks"),
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

////////////////////////////////////////////////////////////
/// ENTRY LIST
////////////////////////////////////////////////////////////

      body: ValueListenableBuilder(
        valueListenable: entriesBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No time entries yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final entry = box.get(key);

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "${entry['task']} • ${entry['time']} hrs",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${entry['project']} \n${entry['date']}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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

////////////////////////////////////////////////////////////
/// ADD ENTRY BUTTON
////////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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

////////////////////////////////////////////////////////////
/// ADD ENTRY SCREEN
////////////////////////////////////////////////////////////

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final projectsBox = Hive.box('projects');
  final tasksBox = Hive.box('tasks');
  final entriesBox = Hive.box('entries');

  String? selectedProject;
  String? selectedTask;

  double? time;
  String notes = "";

  @override
  Widget build(BuildContext context) {
    List projects = projectsBox.values.toList();
    List tasks = tasksBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Add Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

////////////////////////////////////////////////////////////
/// TIME FIELD
////////////////////////////////////////////////////////////

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Hours Spent",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Enter time" : null,
                onSaved: (value) => time = double.parse(value!),
              ),

              const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// PROJECT DROPDOWN
////////////////////////////////////////////////////////////

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Project",
                  border: OutlineInputBorder(),
                ),
                items: projects.map((p) {
                  return DropdownMenuItem(
                    value: p.toString(),
                    child: Text(p.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProject = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Select project" : null,
              ),

              const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// TASK DROPDOWN
////////////////////////////////////////////////////////////

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Task",
                  border: OutlineInputBorder(),
                ),
                items: tasks.map((t) {
                  return DropdownMenuItem(
                    value: t.toString(),
                    child: Text(t.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTask = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Select task" : null,
              ),

              const SizedBox(height: 15),

////////////////////////////////////////////////////////////
/// NOTES
////////////////////////////////////////////////////////////

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => notes = value,
              ),

              const SizedBox(height: 25),

////////////////////////////////////////////////////////////
/// SAVE BUTTON
////////////////////////////////////////////////////////////

              ElevatedButton(
                child: const Text("Save Entry"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    entriesBox.add({
                      "project": selectedProject,
                      "task": selectedTask,
                      "time": time,
                      "notes": notes,
                      "date": DateTime.now()
                          .toString()
                          .split(" ")[0],
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

////////////////////////////////////////////////////////////
/// PROJECT SCREEN
////////////////////////////////////////////////////////////

class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsBox = Hive.box('projects');

    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),

      body: ValueListenableBuilder(
        valueListenable: projectsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No projects"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);

              return ListTile(
                title: Text(box.get(key)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => box.delete(key),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addProject(context, projectsBox),
      ),
    );
  }

  void _addProject(BuildContext context, Box box) {
    String name = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Project"),
        content: TextField(
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (name.isNotEmpty) box.add(name);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// TASK SCREEN
////////////////////////////////////////////////////////////

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');

    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),

      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No tasks"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);

              return ListTile(
                title: Text(box.get(key)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => box.delete(key),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addTask(context, tasksBox),
      ),
    );
  }

  void _addTask(BuildContext context, Box box) {
    String name = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (name.isNotEmpty) box.add(name);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
