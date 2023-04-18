import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() =>
      _TodoListPageState(); //state class 를 가지고 있음.
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    //페이지를 초기화 할 때 가져옴
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        // replacement: const Center(child: CircularProgressIndicator()),
        child: RefreshIndicator(
          onRefresh: fetchTodo,

          child: ListView.builder(
              //검색해볼것
              itemCount: items.length,//get 요청으로 받아온 객체의 길이로 조정
              itemBuilder: (context, index) {

                final item = items[index] as Map;//
                final id = item['_id'] as String;

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value){
                      if(value == 'edit'){
                        //Open Edit Page
                        navigateToEditPage(item);
                      }else if (value == 'delete') {
                        // Delete and remove the item.
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context){
                      return [
                        const PopupMenuItem(
                            value: 'edit',
                          child: Text("Edit"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        )
                      ];
                    },
                  ),
                );


              }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, //함수 포인터 전달
          label: const Text('Add todo')),
    );
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) =>const AddTodoPage(),
    );
    await Navigator.push(context, route);

    fetchTodo();
  }

  Future<void> navigateToEditPage (Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );

    await Navigator.push(context, route);

    fetchTodo();
  }

    Future<void> deleteById(String id) async{
        final url = 'https://api.nstack.in/v1/todos/$id';
        final uri = Uri.parse(url);
        final response = await http.delete(uri);

        if(response.statusCode == 200){
          //remove item froim the list
          final filtered = items.where((element)=> element['_id'] != id).toList();//where에서 프리디켓을 반환하는 call back function을 넘겨줌
          setState(() {
            items = filtered;
          });

          showSuccessMessage("Deleted!");
        }else{
          //show error
          showErrorMessage('Deleteion Filed');
        }
    }


    Future<void> fetchTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });

    }


    print(response.statusCode);
    print(response.body);
  }

  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }



  void showSuccessMessage(String message){
    final snackBar = SnackBar(
      content: Text(
          message,
          style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.green,

    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
