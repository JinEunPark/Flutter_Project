import 'package:flutter/material.dart';
import 'package:myfirst_todo_flutter/screens/list_todo.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  Widget build(BuildContext context){
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),//테마 지정함.
      home: const TodoListPage(),
    );
  }
}


