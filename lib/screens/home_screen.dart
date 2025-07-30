// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFFFF176),
//           title: const Text(
//             'My Todos',
//             style: TextStyle(
//               color: Colors.blueGrey,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 2,
//         ),
//         backgroundColor: const Color(0xFFFFF9C4),
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.06),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: height * 0.04),
//               const Text(
//                 'Today\'s Tasks',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueGrey,
//                 ),
//               ),
//               SizedBox(height: height * 0.02),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: 5, // geçici veri
//                   itemBuilder: (context, index) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(vertical: 10),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.9),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 6,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.check_circle_outline, color: Colors.blueGrey),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'Todo Item #$index',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.blueGrey,
//                               ),
//                             ),
//                           ),
//                           const Icon(Icons.chevron_right, color: Colors.blueGrey),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.blueGrey,
//           elevation: 6,
//           shape: const CircleBorder(),
//           onPressed: () {
//             // Yeni görev ekleme ekranına gidecek
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/screens/add_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TodoModel> _todos = [];

  void _addTodo(TodoModel todo) {
    setState(() {
      _todos.add(todo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF176),
        title: const Text(
          'My Todos',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFFFF9C4),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.04),
            const Text(
              'Today\'s Tasks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: _todos.isEmpty
                  ? const Center(
                      child: Text("No tasks yet."),
                    )
                  : ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final todo = _todos[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.blueGrey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.blueGrey),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTodoScreen(onAdd: _addTodo),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
