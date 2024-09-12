import 'package:flutter/material.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const double textSize = 20.0; // Define the desired text size

class PromptManagementPage extends StatefulWidget {
  @override
  _PromptManagementPageState createState() => _PromptManagementPageState();
}

class _PromptManagementPageState extends State<PromptManagementPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _items = [
    {'title': '生成英文講稿', 'description': '幫我生成英文講稿', 'isStarred': false},
    {'title': '本堂課程介紹', 'description': '幫我依據這頁的內容生成本堂課的課程介紹', 'isStarred': false},
    {'title': '生成示意圖', 'description': '幫我依據這頁的內容生成示意圖', 'isStarred': false},
    {'title': '產生隨堂測驗', 'description': '幫我依據這頁的內容產生隨堂測驗', 'isStarred': false},
    {'title': '指定文字風格、語氣', 'description': '幫我用...的文字風格來生成英文講稿', 'isStarred': false},
  ];
  List<Map<String, dynamic>> _filteredItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_items); // Ensure _filteredItems is a copy of _items
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_items); // Reset to all items
      } else {
        _filteredItems = _items.where((item) {
          return item['title'].toLowerCase().contains(query.toLowerCase()) ||
              item['description'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredItems = List.from(_items); // Reset to all items
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 100.0, top: 75.0, right: 100.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '按enter搜尋...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: textSize),
                      contentPadding: EdgeInsets.only(left: 20.0),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.white54),
                            onPressed: _clearSearch,
                          ),
                          IconButton(
                            icon: Icon(Icons.search, color: Colors.white54),
                            onPressed: () => _filterItems(_searchController.text),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0), // Add padding after search button
                          ),
                        ],
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: textSize),
                    onSubmitted: (value) => _filterItems(value), // Handle 'Enter' key press
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.0), // Add padding after search button
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.white, // Background color
                    foregroundColor: backgroundColor, // Text color
                  ),
                  child: Text('新增Prompt', style: TextStyle(fontSize: textSize)),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        '無符合項目',
                        style: TextStyle(color: Colors.white, fontSize: textSize),
                      ),
                    )
                  : AnimatedList(
                      key: _listKey,
                      initialItemCount: _filteredItems.length,
                      itemBuilder: (context, index, animation) {
                        if (index < 0 || index >= _filteredItems.length) {
                          return Container(); // Return an empty container if the index is out of bounds
                        }
                        return _buildItem(_filteredItems[index], animation, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增Prompt', style: TextStyle(fontSize: textSize)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題', labelStyle: TextStyle(fontSize: textSize)),
                style: TextStyle(fontSize: textSize),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Prompt描述', labelStyle: TextStyle(fontSize: textSize)),
                style: TextStyle(fontSize: textSize),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消', style: TextStyle(fontSize: textSize)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  var newItem = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'isStarred': false
                  };
                  _items.add(newItem);
                  _filteredItems.add(newItem);
                  int index = _filteredItems.length - 1;
                  if (index >= 0 && index <= _filteredItems.length) {
                    _listKey.currentState?.insertItem(index);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('新增', style: TextStyle(fontSize: textSize)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(Map<String, dynamic> item, Animation<double>? animation, int index) {
    Widget listItem = ListTile(
      title: Text(
        item['title'],
        style: TextStyle(color: Colors.white, fontSize: textSize),
      ),
      subtitle: Text(
        item['description'],
        style: TextStyle(color: Colors.white70, fontSize: textSize - 4),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              item['isStarred'] ? Icons.star : Icons.star_border,
              color: Colors.white54,
            ),
            onPressed: () => _starItem(index),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white54),
            onPressed: () => _editItem(index),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white54),
            onPressed: () => _deleteItem(index),
          ),
        ],
      ),
    );
    if (animation != null) {
      return SizeTransition(
        sizeFactor: animation,
        child: listItem,
      );
    } else {
      return listItem;
    }
  }

  void _starItem(int index) {
    setState(() {
      var starredItem = _filteredItems[index];
      bool isStarred = starredItem['isStarred'];
      int removeIndex = index;
      int insertIndex = isStarred ? _filteredItems.length - 1 : 0;
      _filteredItems.removeAt(removeIndex);
      _listKey.currentState?.removeItem(
        removeIndex,
        (context, animation) => _buildItem(starredItem, animation, removeIndex),
      );
      starredItem['isStarred'] = !isStarred;
      _filteredItems.insert(insertIndex, starredItem);
      _listKey.currentState?.insertItem(insertIndex);
      // Update the original list
      var originalIndex = _items.indexWhere((item) => item['title'] == starredItem['title']);
      if (originalIndex != -1) {
        _items.removeAt(originalIndex);
        if (starredItem['isStarred']) {
          _items.insert(0, starredItem); // Move to top if starred
        } else {
          _items.add(starredItem); // Move to last if unstarred
        }
      }
    });
  }

  void _editItem(int index) {
    TextEditingController titleController = TextEditingController(text: _filteredItems[index]['title']);
    TextEditingController descriptionController = TextEditingController(text: _filteredItems[index]['description']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('編輯Prompt', style: TextStyle(fontSize: textSize)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題', labelStyle: TextStyle(fontSize: textSize)),
                style: TextStyle(fontSize: textSize),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Prompt描述', labelStyle: TextStyle(fontSize: textSize)),
                style: TextStyle(fontSize: textSize),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消', style: TextStyle(fontSize: textSize)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filteredItems[index]['title'] = titleController.text;
                  _filteredItems[index]['description'] = descriptionController.text;
                  // Update the original list
                  var originalIndex = _items.indexWhere((item) => item['title'] == _filteredItems[index]['title']);
                  if (originalIndex != -1) {
                    _items[originalIndex]['title'] = titleController.text;
                    _items[originalIndex]['description'] = descriptionController.text;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('儲存', style: TextStyle(fontSize: textSize)),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      // Remove the item from the filtered list
      var deletedItem = _filteredItems.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildItem(deletedItem, animation, index),
      );
      // Remove the item from the original list
      var originalIndex = _items.indexWhere((item) => item['title'] == deletedItem['title']);
      if (originalIndex != -1) {
        _items.removeAt(originalIndex);
      }
    });
  }
}