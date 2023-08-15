import 'package:flutter/material.dart';

class ModelButton extends StatelessWidget {
  final Function addTask;

  ModelButton({
    super.key,
    required this.addTask,
  });

  // String textValue = '';
  TextEditingController textEditingController = TextEditingController();
  void _handleOnClick(BuildContext context) {
    final name = textEditingController.text;

    if (name.isEmpty) {
      return;
    }

    addTask(name);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 200,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            TextField(
              // onChanged: (value) => {textValue = value},
              controller: textEditingController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Your task'),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: () {
                    _handleOnClick(context);
                  },
                  child: const Text(
                    'Add task',
                    style: TextStyle(fontSize: 30),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
