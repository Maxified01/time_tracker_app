import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open boxes
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
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1565C0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
      appBar: AppBar(
        title: const Text("Time Tracker"),
        elevation: 0,
      ),

////////////////////////////////////////////////////////////
/// DRAWER
////////////////////////////////////////////////////////////

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0D47A1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Time Tracker",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Manage your time effectively",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Color(0xFF0D47A1)),
              title: const Text(
                "Projects",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProjectScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task, color: Color(0xFF0D47A1)),
              title: const Text(
                "Tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No time entries yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first entry",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final entry = box.get(key);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry['task'] ?? 'Unknown Task',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${entry['time']} hrs",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Project: ${entry['project'] ?? 'No Project'}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry['date'] ?? 'No date',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (entry['notes'] != null && entry['notes'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entry['notes'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, box, key),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Entry"),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Box box, dynamic key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Entry"),
          content: const Text("Are you sure you want to delete this time entry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                box.delete(key);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
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
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  String? selectedProject;
  String? selectedTask;
  List<String> projects = [];
  List<String> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final projectsBox = Hive.box('projects');
    final tasksBox = Hive.box('tasks');
    
    setState(() {
      projects = projectsBox.values.cast<String>().toList();
      tasks = tasksBox.values.cast<String>().toList();
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Time Entry"),
        elevation: 0,
      ),

      body: ValueListenableBuilder(
        valueListenable: Hive.box('projects').listenable(),
        builder: (context, Box projectsBox, _) {
          // Update projects list when changes occur
          projects = projectsBox.values.cast<String>().toList();
          
          return ValueListenableBuilder(
            valueListenable: Hive.box('tasks').listenable(),
            builder: (context, Box tasksBox, __) {
              // Update tasks list when changes occur
              tasks = tasksBox.values.cast<String>().toList();
              
              // Reset selections if current selection no longer exists
              if (selectedProject != null && !projects.contains(selectedProject)) {
                selectedProject = null;
              }
              if (selectedTask != null && !tasks.contains(selectedTask)) {
                selectedTask = null;
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Show message if no projects or tasks
                      if (projects.isEmpty || tasks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade800,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                projects.isEmpty && tasks.isEmpty
                                    ? "Please add at least one project and one task first"
                                    : projects.isEmpty
                                        ? "Please add at least one project first"
                                        : "Please add at least one task first",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (projects.isEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const ProjectScreen()),
                                        ).then((_) => _loadData());
                                      },
                                      icon: const Icon(Icons.folder, size: 18),
                                      label: const Text("Add Project"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                      ),
                                    ),
                                  if (projects.isEmpty && tasks.isEmpty)
                                    const SizedBox(width: 10),
                                  if (tasks.isEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => const TaskScreen()),
                                        ).then((_) => _loadData());
                                      },
                                      icon: const Icon(Icons.task, size: 18),
                                      label: const Text("Add Task"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade800,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

////////////////////////////////////////////////////////////
/// TIME FIELD
////////////////////////////////////////////////////////////

                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: "Hours",
                          hintText: "Enter time in hours (e.g., 2.5)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.timer),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter hours";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number";
                          }
                          if (double.parse(value) <= 0) {
                            return "Hours must be greater than 0";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

////////////////////////////////////////////////////////////
/// PROJECT DROPDOWN
////////////////////////////////////////////////////////////

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Project",
                          hintText: "Select a project",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.folder),
                        ),
                        value: selectedProject,
                        items: [
                          ...projects.map((project) {
                            return DropdownMenuItem<String>(
                              value: project,
                              child: Text(project),
                            );
                          }).toList(),
                        ],
                        onChanged: projects.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedProject = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a project";
                          }
                          return null;
                        },
                        hint: const Text("Choose a project"),
                      ),

                      const SizedBox(height: 16),

////////////////////////////////////////////////////////////
/// TASK DROPDOWN
////////////////////////////////////////////////////////////

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Task",
                          hintText: "Select a task",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.task),
                        ),
                        value: selectedTask,
                        items: [
                          ...tasks.map((task) {
                            return DropdownMenuItem<String>(
                              value: task,
                              child: Text(task),
                            );
                          }).toList(),
                        ],
                        onChanged: tasks.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedTask = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select a task";
                          }
                          return null;
                        },
                        hint: const Text("Choose a task"),
                      ),

                      const SizedBox(height: 16),

////////////////////////////////////////////////////////////
/// NOTES
////////////////////////////////////////////////////////////

                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: "Notes (Optional)",
                          hintText: "Add any additional notes",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

////////////////////////////////////////////////////////////
/// SAVE ENTRY BUTTON
////////////////////////////////////////////////////////////

                      ElevatedButton(
                        onPressed: (projects.isEmpty || tasks.isEmpty)
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _saveEntry();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save Entry",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _saveEntry() {
    final entriesBox = Hive.box('entries');
    
    entriesBox.add({
      "project": selectedProject,
      "task": selectedTask,
      "time": double.parse(_timeController.text),
      "notes": _notesController.text,
      "date": DateTime.now().toString().split(" ")[0],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Time entry saved successfully!"),
        backgroundColor: Color(0xFF0D47A1),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}

////////////////////////////////////////////////////////////
/// PROJECT SCREEN
////////////////////////////////////////////////////////////

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _projectController = TextEditingController();

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsBox = Hive.box('projects');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        elevation: 0,
      ),

      body: ValueListenableBuilder(
        valueListenable: projectsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No projects yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first project",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final project = box.get(key);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                    child: const Icon(
                      Icons.folder,
                      color: Color(0xFF0D47A1),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    project,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, box, key),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context, projectsBox),
        icon: const Icon(Icons.add),
        label: const Text("Add Project"),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, Box box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Project"),
          content: TextField(
            controller: _projectController,
            decoration: const InputDecoration(
              hintText: "Enter project name",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _projectController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_projectController.text.isNotEmpty) {
                  box.add(_projectController.text);
                  _projectController.clear();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Project '${_projectController.text}' added"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Box box, dynamic key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Project"),
          content: const Text("Are you sure you want to delete this project?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                box.delete(key);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// TASK SCREEN
////////////////////////////////////////////////////////////

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        elevation: 0,
      ),

      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No tasks yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first task",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = box.keyAt(index);
              final task = box.get(key);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                    child: const Icon(
                      Icons.task,
                      color: Color(0xFF0D47A1),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    task,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, box, key),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, tasksBox),
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, Box box) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              hintText: "Enter task name",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _taskController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  box.add(_taskController.text);
                  _taskController.clear();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Task '${_taskController.text}' added"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Box box, dynamic key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                box.delete(key);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
