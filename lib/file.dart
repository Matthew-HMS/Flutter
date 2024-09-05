import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'course.dart';
import 'ppt.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);

class FilePage extends StatefulWidget {
  final String courseName;
  final List<String> files;
  final List<String> otherFiles;

  FilePage({
    required this.courseName,
    required this.files,
    required this.otherFiles,
  });

  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  PageController _pageController = PageController();
  List<Widget> fileTiles = [];
  List<Widget> otherFileTiles = [];
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _otherFileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fileTiles.add(AddCourseTile(onAddCourse: pickFile, text: '新增簡報'));
    otherFileTiles.add(AddCourseTile(onAddCourse: pickOtherFile, text: '新增補充教材'));
    for (var file in widget.files) {
      fileTiles.add(FileTile(
        title: file,
        filePath: '',
        courseName: widget.courseName,
        onDelete: deleteFileTile,
        onUpdate: updateFileName,
        onTap: () {
          navigateToPptPage('');
        },
      ));
    }
    for (var otherfile in widget.otherFiles) {
      otherFileTiles.add(FileTile(
        title: otherfile,
        filePath: '',
        courseName: widget.courseName,
        onDelete: deleteFileTile,
        onUpdate: updateFileName,
        onTap: () {},
      ));
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      addFileTile(filePath);
    }
  }

  Future<void> pickOtherFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      addOtherFileTile(filePath);
    }
  }

  void addFileTile(String filePath) {
    String fileName = path.basename(filePath);
    setState(() {
      fileTiles.insert(
        fileTiles.length,
        FileTile(
          key: UniqueKey(),
          title: fileName,
          courseName: widget.courseName,
          filePath: filePath,
          onDelete: deleteFileTile,
          onUpdate: updateFileName,
          onTap: () {
            navigateToPptPage(filePath);
          },
        ),
      );
      widget.files.add(fileName);
    });
  }

  void addOtherFileTile(String filePath) {
    String fileName = path.basename(filePath);
    setState(() {
      otherFileTiles.insert(
        otherFileTiles.length,
        FileTile(
          key: UniqueKey(),
          title: fileName,
          filePath: filePath,
          courseName: widget.courseName,
          onDelete: deleteFileTile,
          onUpdate: updateFileName,
        ),
      );
      widget.otherFiles.add(fileName);
    });
  }

  void deleteFileTile(String fileName) {
    setState(() {
      // Check the current page index. Assuming 0 is for 'files' and 1 is for 'otherFiles'.
      int currentPage = _pageController.page?.round() ?? 0; // Default to 0 if null
      List<Widget> tiles = currentPage == 0 ? fileTiles : otherFileTiles;
      List<String> filesList = currentPage == 0 ? widget.files : widget.otherFiles;

      // Remove the tile and the file name from the respective lists
      tiles.removeWhere((element) {
        if (element is FileTile) {
          return element.title == fileName;
        }
        return false;
      });
      filesList.remove(fileName);
    });
  }

  void updateFileName(String oldName, String newName) {
    setState(() {
      int currentPage = _pageController.page?.round() ?? 0;
      if (currentPage == 0) {
        int index = widget.files.indexOf(oldName);
        if (index != -1) {
          widget.files[index] = newName;
        }
      } else {
        int index = widget.otherFiles.indexOf(oldName);
        if (index != -1) {
          widget.otherFiles[index] = newName;
        }
      }
    });
  }

  void navigateToPptPage(String filePath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PptPage(filePath: filePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 48, 48, 48), // Set button color to black
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    '課程簡報',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 48, 48, 48), // Set button color to black
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    '補充教材',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30), // Set icon color to white
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Number of columns
                              crossAxisSpacing: 75, // Horizontal spacing between items
                              mainAxisSpacing: 75, // Vertical spacing between items
                            ),
                            itemCount: fileTiles.length,
                            itemBuilder: (context, index) {
                              return fileTiles[index];
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Number of columns
                              crossAxisSpacing: 75, // Horizontal spacing between items
                              mainAxisSpacing: 75, // Vertical spacing between items
                            ),
                            itemCount: otherFileTiles.length,
                            itemBuilder: (context, index) {
                              return otherFileTiles[index];
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FileTile extends StatefulWidget {
  final String title;
  final String courseName;
  final String filePath;
  final Function(String) onDelete;
  final Function(String, String) onUpdate;
  final Function()? onTap;

  FileTile({
    Key? key,
    required this.title,
    required this.courseName,
    required this.filePath,
    required this.onDelete,
    required this.onUpdate,
    this.onTap,
  }) : super(key: key);

  @override
  _FileTileState createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  void didUpdateWidget(FileTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      setState(() {
        _title = widget.title;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("FileTile tapped");
        widget.onTap?.call();
      },
      child: Card(
        color: Color.fromARGB(255, 48, 48, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(), // Pushes the icon to the center vertically
            Icon(
              Icons.insert_drive_file,
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
                      } else if (newValue == '刪除檔案') {
                        widget.onDelete(_title);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <String>['編輯名稱', '刪除檔案']
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
                  widget.onUpdate(_title, newTitle);
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
