import 'package:flutter/material.dart';

// edit by chou
import 'api_prompt.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
// class PersonalInfoPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//    return Scaffold(
//       backgroundColor: backgroundColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'This is a personal information page',
//               style: TextStyle(color: Colors.white),
//             ),
//             // Add more elements here if needed
//           ],
//         ),
//       ),
//     );
//   }
// }


class PersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Django-Flutter App'),
        ),
        body: FutureBuilder<List<Prompt>>(
          future: ApiService.fetchModels(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final prompt = snapshot.data![index];
                  print('user_id: ${prompt.user_id}');
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\'name\': \'${prompt.name}\'',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\'content\': \'${prompt.content}\'',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\'ID\': \'${prompt.user_id}\'',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
