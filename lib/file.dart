import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'course.dart';
import 'ppt.dart';
import 'api_file.dart' as apiFile;
import 'api_ppt.dart' as apiPpt;

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);

class FilePage extends StatefulWidget {
  final String courseName;
  final int class_id;
  final List<String> files;
  final List<String> otherFiles;

  FilePage({
    required this.courseName,
    required this.class_id,
    required this.files,
    required this.otherFiles,
  });

  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  PageController _pageController = PageController();
  List<Widget> pptFileTiles = [];
  List<Widget> otherFileTiles = [];
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _otherFileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pptFileTiles.add(AddCourseTile(onAddCourse: pickPptFile, text: '新增簡報'));
    otherFileTiles.add(AddCourseTile(onAddCourse: pickOtherFile, text: '新增補充教材'));
    _fetchPptFiles();
    _fetchOtherFiles();
  }

  Future<void> _fetchPptFiles() async {
    try {
      List<apiPpt.Ppt> Ppts = await apiPpt.ApiService.fetchModels(widget.class_id);
      setState(() {
        pptFileTiles = [
          AddCourseTile(onAddCourse: pickPptFile),
          ...Ppts.map((Ppt) {
            return FileTile(
              file_id: Ppt.ppt_id,
              title: Ppt.ppt_name,
              file_path: Ppt.ppt_path,
              courseName: widget.courseName,
              onDelete: () => deletePptFileTile(Ppt.ppt_id),
              onUpdate: updateFileName,
              onTap: () {
                navigateToPptPage();
              },
            );
          }).toList(),
        ];
      });
    } catch (e) {
      print('Failed to fetchPptFiles: $e');
    }
  }

  Future<void> _fetchOtherFiles() async {
    try {
      List<apiFile.File> files = await apiFile.ApiService.fetchModels(widget.class_id);
      setState(() {
        otherFileTiles = [
          AddCourseTile(onAddCourse: pickOtherFile),
          ...files.map((file) {
            return FileTile(
              file_id: file.file_id,
              title: file.file_name,
              file_path: file.file_path,
              courseName: widget.courseName,
              onDelete: () => deleteOtherFileTile(file.file_id),
              onUpdate: updateFileName,
              onTap: () {
                // navigateToPptPage();
              },
            );
          }).toList(),
        ];
      });
    } catch (e) {
      print('Failed to fetchOtherFiles: $e');
    }
  }

  Future<void> pickPptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;
      addPptFileTile(fileName, filePath, widget.class_id);
    }
  }

  Future<void> pickOtherFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;
      addOtherFileTile(fileName, filePath, widget.class_id);
    }
  }

  void addPptFileTile(String fileName, String filePath, int class_id) async {
    try {      
      final response = await apiPpt.ApiService.createPpt(fileName, filePath, class_id);
      if (response.statusCode == 201) {
        _fetchOtherFiles(); // 新增成功後重新載入課程
      }           
    } catch (e) {
      print('Failed to create PptFile: $e');
    }
  }

  void addOtherFileTile(String fileName, String filePath, int class_id) async {
    try {      
      final response = await apiFile.ApiService.createFile(fileName, filePath, class_id);
      if (response.statusCode == 201) {
        _fetchOtherFiles(); // 新增成功後重新載入課程
      }           
    } catch (e) {
      print('Failed to create OtherFile: $e');
    }
  }

  void deletePptFileTile(int ppt_id) async {
    try {      
      final response = await apiPpt.ApiService.deletePpt(ppt_id);
      if (response.statusCode == 204) {
        _fetchPptFiles();
      }           
    } catch (e) {
      print('Failed to delete PptFile: $e');
    }
  }

  void deleteOtherFileTile(int file_id) async {
    try {      
      final response = await apiFile.ApiService.deleteFile(file_id);
      if (response.statusCode == 204) {
        _fetchOtherFiles();
      }           
    } catch (e) {
      print('Failed to delete OtherFile: $e');
    }
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

  void navigateToPptPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PptPage(key: UniqueKey())),
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
                            itemCount: pptFileTiles.length,
                            itemBuilder: (context, index) {
                              return pptFileTiles[index];
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
  final int file_id;
  final String title;
  final String file_path;
  final String courseName;
  final Function() onDelete;
  final Function(String, String) onUpdate;
  final Function()? onTap;

  FileTile({
    Key? key,
    required this.file_id,
    required this.title,
    required this.file_path,
    required this.courseName,
    required this.onDelete,
    required this.onUpdate,
    this.onTap,
  }) : super(key: key) ;

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
                        widget.onDelete();
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