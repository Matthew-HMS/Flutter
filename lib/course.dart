import 'package:flutter/material.dart';
import 'file.dart';
import 'api_course.dart';
import 'dart:io';

const Color backgroundColor = Color.fromARGB(255, 249, 247, 247);

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  get fileManager => null;

  @override
  CourseManagementPageState createState() => CourseManagementPageState();
}

class CourseManagementPageState extends State<CourseManagementPage> {
  List<Widget> courseTiles = [];
  final TextEditingController _courseNameController = TextEditingController();
  Map<String, List<String>> courseFiles = {};
  Map<String, List<String>> otherCourseFiles = {};

  @override
  void initState() {
    super.initState();
    // Add the AddCourseTile initially
    courseTiles.add(AddCourseTile(onAddCourse: promptCourseName));
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      List<Course> courses = await ApiService.fetchModels();
      setState(() {
        courseTiles = [
          AddCourseTile(onAddCourse: promptCourseName),
          ...courses.map((course) {
            return CourseTile(
              title: course.name,
              class_id: course.class_id,
              courseManager: this,
            );
          }).toList(),
        ];
      });
    } catch (e) {
      print('Failed to fetchCourses: $e');
    }
  }

  void addCourseTile(String courseName) async {
    try {
      // create course directory in /assets
      String basePath = Directory.current.path;  // 獲取當前專案的路徑
      String directoryPath = '$basePath/assets/$courseName';
      Directory newDirectory = Directory(directoryPath);

      if (!newDirectory.existsSync()) { // undo: must show alert if directory exists
        newDirectory.createSync(recursive: true);
        print('Directory created: $directoryPath');
        final response = await ApiService.createCourse(courseName, '');
        if (response.statusCode == 201) {
          _fetchCourses(); // 新增成功後重新載入課程
        }
      } else {
        print('Directory already exists: $directoryPath');
      }      
    } catch (e) {
      print('Failed to create course: $e');
    }
    finally{
      _fetchCourses(); // 新增成功後重新載入課程
    }
  }

  void deleteCourseTile(int class_id, String courseName) async {
    try {
      print("call deleteCourseTile");
      final response = await ApiService.deleteCourse(class_id);
      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 204) {
        // 刪除對應的資料夾及其內容
        String basePath = Directory.current.path;  // 獲取當前專案的路徑
        String directoryPath = '$basePath/assets/$courseName';
        Directory directoryToDelete = Directory(directoryPath);

        if (directoryToDelete.existsSync()) {
          try {
            // 刪除資料夾及其所有內容
            directoryToDelete.deleteSync(recursive: true);
            print('Directory deleted: $directoryPath');
          } catch (e) {
            print('Failed to delete directory: $e');
          }
        } else {
          print('Directory does not exist: $directoryPath');
        }    
      }
    } catch (e) {
      print('Failed to delete course: $e');
    }
    finally{
      _fetchCourses(); // 刪除成功後重新載入課程
    }
  }

  void updateCourseTileTitle(int class_id, String newCourseName, String courseName) async {
    print('Class ID: $class_id, New Title: $newCourseName');
    Course course = Course(class_id: class_id, name: newCourseName, user_id: 1);//預設為 1
    try {
      final response = await ApiService.editCourse(course);
      if (response.statusCode == 200) { 
        // edit course directory in /assets
        String basePath = Directory.current.path;
        String directoryPath = '$basePath/assets/$courseName';
        String newDirectoryPath = '$basePath/assets/$newCourseName';
        Directory oldDirectory = Directory(directoryPath);
        if (oldDirectory.existsSync()) {
          // 重新命名資料夾
          oldDirectory.renameSync(newDirectoryPath);
          print('Directory renamed from $directoryPath to $newDirectoryPath');
        } else {
          print('Old directory does not exist: $directoryPath');
        }
        // reload course tiles
        _fetchCourses();      
      }
    } catch (e) {
      print('Failed to update course: $e');
    }
    finally{
      // reload course tiles
      _fetchCourses(); 
    }
  }

  void addFileToCourse(String courseName, String fileName) {
    setState(() {
      courseFiles[courseName]?.add(fileName);
    });
  }

  void addOtherFileToCourse(String courseName, String fileName) {
    setState(() {
      otherCourseFiles[courseName]?.add(fileName);
    });
  }

  List<String> getFilesForCourse(String courseName) {
    return courseFiles[courseName] ?? [];
  }

  List<String> getOtherFilesForCourse(String courseName) {
    return otherCourseFiles[courseName] ?? [];
  }

  void promptCourseName() {
    if (!mounted) return;
    _courseNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('請輸入課程名稱'),
          content: TextField(
            controller: _courseNameController,
            decoration: InputDecoration(hintText: 'Course Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('加入'),
              onPressed: () {
                addCourseTile(_courseNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Number of columns
                  crossAxisSpacing: 75, // Horizontal spacing between items
                  mainAxisSpacing: 75, // Vertical spacing between items
                ),
                itemCount: courseTiles.length,
                itemBuilder: (context, index) {
                  return courseTiles[index];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseTile extends StatefulWidget {
  String title;
  int class_id;
  final String? imageUrl;
  final CourseManagementPageState courseManager;

  CourseTile({required this.title, required this.class_id, this.imageUrl, required this.courseManager});

  @override
  _CourseTileState createState() => _CourseTileState();
}

class _CourseTileState extends State<CourseTile> {
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  void didUpdateWidget(CourseTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      setState(() {
        _title = widget.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FilePage( // Change to FilePage
              courseName: _title,
              class_id: widget.class_id,
              files: widget.courseManager.getFilesForCourse(_title),
              otherFiles: widget.courseManager.getOtherFilesForCourse(_title),
            ),
          ),
        );
      },
      child: Card(
        color: Color.fromARGB(255, 219, 226, 239),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(), // Pushes the icon to the center vertically
            if (widget.imageUrl != null)
              Image.asset(widget.imageUrl!)
            else
              Icon(
                Icons.book_outlined,
                size: 100,
                color: Color.fromARGB(255, 63, 114, 175),
              ),
            Spacer(), // Pushes the title and button to the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Add padding from the bottom
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _title,
                      style: TextStyle(color: Color.fromARGB(255, 63, 114, 175)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    onSelected: (String newValue) {
                      if (newValue == '編輯名稱') {
                        showEditDialog(context);
                      } else if (newValue == '刪除課程') {
                        widget.courseManager.deleteCourseTile(widget.class_id, _title);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <String>['編輯名稱', '刪除課程']
                          .map<PopupMenuItem<String>>((String value) {
                        return PopupMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList();
                    },
                    color: Color.fromARGB(255, 61, 61, 61),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('編輯名稱'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'New title'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('保存'),
              onPressed: () {
                setState(() {
                  String newTitle = _controller.text;
                  widget.courseManager.updateCourseTileTitle(widget.class_id, newTitle, _title);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddCourseTile extends StatelessWidget {
  final VoidCallback onAddCourse;

  const AddCourseTile({required this.onAddCourse});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAddCourse,
      child: Card(
        color: Color.fromARGB(255, 219, 226, 239),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 100,
              color: Color.fromARGB(255, 63, 114, 175), // Change 'Colors.red' to your desired color
            ),
            SizedBox(height: 8),
            
          ],
        ),
      ),
    );
  }
}