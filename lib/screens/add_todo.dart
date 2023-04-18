import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //http 의존성 추가함.

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo,

  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {

  TextEditingController titleController = TextEditingController(); // controller 생성함.
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState(){
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text =  title;
      descriptionController.text = description;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Todo': 'AddTodo'),
        ),
        body: ListView(

          padding: const EdgeInsets.all(50),

          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "InputTitle"),
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  hintText: "Input todo description"),
              keyboardType: TextInputType.multiline,
              //key board 가 같이 움직이.
              minLines: 5,
              maxLines: 8,
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
                onPressed: isEdit ? updateData : submitData,
                child: Text(isEdit ? 'update!': 'submit!')
            )

          ],
        )
    );
  }

  Future<void> updateData() async{

    final todo = widget.todo;
    if (todo == null){
      print('You cna not call updated without todo data');
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri, body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    ); //await 키워드를 사용해서 Future로 감싼 객체의 데이터를 받을 수도 있다.

    if(response.statusCode == 200){
      titleController.text = '';// controller 문자열을 초기화함.
      descriptionController.text = '';
      showSuccessMessage(" updating success!!");

    }else{
      showErrorMessage("updating Fail!!");
    }

  }
  // Future<int> 라는 상자가 있는데, 이 상자는 지금은 닫혀있다. 하지만 이 상자를 준 함수가 말한다.
  //
  // "지금은 그 상자가 닫혀있지만, 나중에 열리면 int 나 error 가 나올거야. 두 경우를 모두 대비해 줘."
  //
  // 이 상자를 받은 변수는 상자로부터 int 가 나올 때를 대비해 then 메소드를, Error 가 나올 경우를 대비해 CatchError 메소드를 준비해야 한다.

  Future<void> submitData() async {
    //get the data from form
    //submit data to the server
    //show success or fail message based on status
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri, body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'}
    ); //await 키워드를 사용해서 Future로 감싼 객체의 데이터를 받을 수도 있다.
    //json encode 해서 데이터를 전달함.
    //원레 비동기 함수는 future 에 싸여져 나와서 이를 처리하기 위해서 then 절을 사용한다 then((변수){변수처리함수}) 로 작성하지 않기 위해서 await 키워드로 처리했다.
    if(response.statusCode == 201){
      titleController.text = '';// controller 문자열을 초기화함.
      descriptionController.text = '';
      showSuccessMessage("success!!");

    }else{
      showErrorMessage("Fail!!");
    }

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
}
