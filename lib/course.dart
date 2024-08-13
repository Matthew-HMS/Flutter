import 'package:flutter/material.dart';
import 'file.dart';
import 'api_course.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);

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
      final response = await ApiService.createCourse(courseName, '');
      if (response.statusCode == 201) {
        _fetchCourses(); // 新增成功後重新載入課程
      }
    } catch (e) {
      print('Failed to create course: $e');
    }
  }

  void deleteCourseTile(int class_id) async {
    try {
      final response = await ApiService.deleteCourse(class_id);
      if (response.statusCode == 204) {
        _fetchCourses(); // 刪除成功後重新載入課程
      }
    } catch (e) {
      print('Failed to delete course: $e');
    }
  }

  void updateCourseTileTitle(int class_id, String newTitle) async {
    print('Class ID: $class_id, New Title: $newTitle');
    Course course = Course(class_id: class_id, name: newTitle, user_id: 1);
    try {
      final response = await ApiService.editCourse(course);
      if (response.statusCode == 200) {
        _fetchCourses(); // 更新成功後重新載入課程
      }
    } catch (e) {
      print('Failed to update course: $e');
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

  // void deleteCourseTile(String courseName) {
  //   setState(() {
  //     courseTiles.remove(
  //       courseTiles.firstWhere(
  //         (element) => element is CourseTile && element.title == courseName,
  //       ),
  //     );
  //     courseFiles.remove(courseName);
  //     otherCourseFiles.remove(courseName);
  //   });
  // }

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
              files: widget.courseManager.getFilesForCourse(_title),
              otherFiles: widget.courseManager.getOtherFilesForCourse(_title),
            ),
          ),
        );
      },
      child: Card(
        color: Color.fromARGB(255, 48, 48, 48),
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
                color: Colors.white,
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
                      style: TextStyle(color: Colors.white),
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
                        widget.courseManager.deleteCourseTile(widget.class_id);
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
                  widget.courseManager.updateCourseTileTitle(widget.class_id, newTitle);
                  _title = newTitle;
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
  final String text;

  const AddCourseTile({required this.onAddCourse, this.text = '新增課程'});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAddCourse,
      child: Card(
        color: Color.fromARGB(255, 48, 48, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 100,
              color: Colors.white, // Change 'Colors.red' to your desired color
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(color: Colors.white), // Change 'Colors.red' to your desired color
            ),
          ],
        ),
      ),
    );
  }
}