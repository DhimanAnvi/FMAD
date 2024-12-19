import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Map<String, dynamic>> _todoItems = [];
  final List<Map<String, dynamic>> _archivedItems = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String _taskFilter = 'All';  // New filter state

  DateTime? _dueDate;  // Store the due date

  // Function to add a new task
  void _addTodoItem(String task) {
    if (task.isNotEmpty && _dueDate != null) {
      String currentDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      setState(() {
        _todoItems.add({
          'task': task,
          'date': currentDateTime,
          'completed': false,
          'dueDate': _dueDate,
        });
      });
      _textController.clear();
      _dueDateController.clear();
      _dueDate = null;
    }
  }

  // Function to select a due date using a date picker
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(_dueDate!);
      });
    }
  }

  void _archiveTodoItem(int index) {
    setState(() {
      _archivedItems.add(_todoItems[index]);
      _todoItems.removeAt(index);
    });
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  void _deleteArchivedItem(int index) {
    setState(() {
      _archivedItems.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _todoItems[index]['completed'] = !_todoItems[index]['completed'];
    });
  }

  // Filtering tasks
  List<Map<String, dynamic>> _getFilteredTodoItems() {
    if (_taskFilter == 'All') {
      return _todoItems; // Show all tasks
    } else if (_taskFilter == 'Completed') {
      return _todoItems.where((task) => task['completed']).toList(); // Show only completed tasks
    } else {  // Pending
      return _todoItems.where((task) => !task['completed']).toList(); // Show only pending tasks
    }
  }

  Widget _buildTodoList() {
    final filteredTodoItems = _getFilteredTodoItems();
    return ListView.builder(
      itemCount: filteredTodoItems.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(filteredTodoItems[index]['task']!),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.archive, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _archiveTodoItem(index);
            } else if (direction == DismissDirection.endToStart) {
              _deleteTodoItem(index);
            }
          },
          child: _buildTodoItem(filteredTodoItems[index]['task']!, filteredTodoItems[index]['date']!, index, filteredTodoItems[index]['completed']!, filteredTodoItems[index]['dueDate']),
        );
      },
    );
  }

  Widget _buildTodoItem(String todoText, String date, int index, bool isCompleted, DateTime? dueDate) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            _toggleTaskCompletion(index);
          },
        ),
        title: Text(
          todoText,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Added on: $date'),
            Text(dueDate != null ? 'Due: ${DateFormat('yyyy-MM-dd').format(dueDate)}' : 'No due date'),
          ],
        ),
      ),
    );
  }

  Widget _buildArchivedList() {
    return ListView.builder(
      itemCount: _archivedItems.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key(_archivedItems[index]['task']!),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd || direction == DismissDirection.endToStart) {
              _deleteArchivedItem(index);
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(_archivedItems[index]['task']!),
              subtitle: Text('Archived on: ${_archivedItems[index]['date']}'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('To Do List'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Tasks'),
              Tab(icon: Icon(Icons.archive), text: 'Archived'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new task',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addTodoItem(_textController.text),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: _addTodoItem,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      hintText: 'Select due date',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDueDate(context),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    value: _taskFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _taskFilter = newValue!;
                      });
                    },
                    items: <String>['All', 'Completed', 'Pending']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(child: _buildTodoList()),
              ],
            ),
            _buildArchivedList(),
          ],
        ),
      ),
    );
  }
}
