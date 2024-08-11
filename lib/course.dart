import 'package:flutter/material.dart';
import 'file.dart';

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
  }

  void addCourseTile(String courseName) {
    setState(() {
      courseTiles.insert(
        courseTiles.length,
        CourseTile(
          title: courseName,
          courseManager: this,
        ),
      );
      courseFiles[courseName] = []; // Initialize the file list for the new course
      otherCourseFiles[courseName] = []; // Initialize the other file list for the new course
    });
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

  void updateCourseTileTitle(String oldTitle, String newTitle) {
    setState(() {
      for (var tile in courseTiles) {
        if (tile is CourseTile && tile.title == oldTitle) {
          tile.title = newTitle;
          break;
        }
      }
      // Update the keys in the maps
      if (courseFiles.containsKey(oldTitle)) {
        courseFiles[newTitle] = courseFiles.remove(oldTitle)!;
      }
      if (otherCourseFiles.containsKey(oldTitle)) {
        otherCourseFiles[newTitle] = otherCourseFiles.remove(oldTitle)!;
      }
    });
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

  void deleteCourseTile(String courseName) {
    setState(() {
      courseTiles.remove(
        courseTiles.firstWhere(
          (element) => element is CourseTile && element.title == courseName,
        ),
      );
      courseFiles.remove(courseName);
      otherCourseFiles.remove(courseName);
    });
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
  final String? imageUrl;
  final CourseManagementPageState courseManager;

  CourseTile({required this.title, this.imageUrl, required this.courseManager});

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
            builder: (context) => FilePage(
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
                        widget.courseManager.deleteCourseTile(_title);
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
                  widget.courseManager.updateCourseTileTitle(_title, newTitle);
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