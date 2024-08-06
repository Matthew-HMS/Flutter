import 'package:flutter/material.dart';
import 'api_prompt.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);

class PromptManagementPage extends StatefulWidget {
  @override
  _PromptManagementPageState createState() => _PromptManagementPageState();
}

class _PromptManagementPageState extends State<PromptManagementPage> {
  TextEditingController _searchController = TextEditingController();
  List<Prompt> _items = []; // 改成 List<Prompt>
  List<Prompt> _filteredItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      print('Current query: ${_searchController.text}'); // Debug print statement
      _filterItems(_searchController.text);
    });
    _fetchPrompts();
  }

  Future<void> _fetchPrompts() async {
    try {
      List<Prompt> prompts = await ApiService.fetchModels();
      setState(() {
        _items = prompts;
        _filteredItems = List.from(_items);
      });
    } catch (e) {
      print(e);
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_items); // Reset to all items
      } else {
        _filteredItems = _items.where((item) {
          return item.name.contains(query) || item.content.contains(query);
        }).toList();
      }
    });
  }

  void _starItem(int index) {
    setState(() {
      var starredItem = _filteredItems[index];
      bool isStarred = starredItem.isStarred;
      int removeIndex = index;
      int insertIndex = isStarred ? _filteredItems.length - 1 : 0;

      _filteredItems.removeAt(removeIndex);
      _listKey.currentState?.removeItem(
        removeIndex,
        (context, animation) => _buildItem(starredItem, animation, removeIndex),
      );

      starredItem.isStarred = !isStarred;
      _filteredItems.insert(insertIndex, starredItem);
      _listKey.currentState?.insertItem(insertIndex);

      // Update the original list
      var originalIndex = _items.indexWhere((item) => item.prompt_id == starredItem.prompt_id);
      if (originalIndex != -1) {
        _items[originalIndex].isStarred = starredItem.isStarred; // 更新原始列表中的星標狀態
      }
    });
  }

  void _editItem(int index) {
    print("edit prompt: "+_filteredItems[index].prompt_id.toString());
    TextEditingController titleController = TextEditingController(text: _filteredItems[index].name);
    TextEditingController descriptionController = TextEditingController(text: _filteredItems[index].content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('編輯Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Prompt描述'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                var editedPrompt = Prompt(
                  prompt_id: _filteredItems[index].prompt_id,
                  name: titleController.text,
                  content: descriptionController.text,
                  user_id: 1, // 預設為 1
                  isStarred: _filteredItems[index].isStarred, // 保持星標狀態
                );
                // setState(() {
                  
                //   _filteredItems[index] = editedPrompt;

                //   // Update the original list
                //   var originalIndex = _items.indexWhere((item) => item.prompt_id == editedPrompt.prompt_id);
                //   if (originalIndex != -1) {
                //     _items[originalIndex] = editedPrompt;
                //   }
                // });
                // Navigator.of(context).pop();
                try {
                  await ApiService.editPrompt(editedPrompt); // 發送 PATCH 請求
                  setState(() {
                    _filteredItems[index] = editedPrompt;

                    // Update the original list
                    var originalIndex = _items.indexWhere((item) => item.prompt_id == editedPrompt.prompt_id);
                    if (originalIndex != -1) {
                      _items[originalIndex] = editedPrompt;
                    }
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print(e);
                }
              },
              child: Text('儲存'),
            ),
          ],
        );
      },
    );
  }


  void _addItem() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Prompt描述'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ApiService.createPrompt(titleController.text, descriptionController.text);
                  // var newItem = Prompt(
                  //   prompt_id: 0, // ID會在API創建後由後端返回，這裡先給一個臨時值
                  //   name: titleController.text,
                  //   content: descriptionController.text,
                  // );
                  // setState(() {
                  //   _items.add(newItem);
                  //   _filteredItems.add(newItem);
                  //   _listKey.currentState?.insertItem(_filteredItems.length - 1);
                  // });
                  // Navigator.of(context).pop();
                  List<Prompt> prompts = await ApiService.fetchModels();
                  setState(() {
                    _items = prompts;
                    _filteredItems = List.from(_items);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print(e);
                }
              },
              child: Text('新增'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) async {
    print("edit prompt: "+_filteredItems[index].prompt_id.toString());
    try {
      var deletedItem = _filteredItems[index];
      await ApiService.deletePrompt(deletedItem.prompt_id);
      setState(() {
        _filteredItems.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildItem(deletedItem, animation, index),
        );

        // Remove the item from the original list
        var originalIndex = _items.indexWhere((item) => item.prompt_id == deletedItem.prompt_id);
        if (originalIndex != -1) {
          _items.removeAt(originalIndex);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildItem(Prompt item, Animation<double>? animation, int index) {
    Widget listItem = ListTile(
      title: Text(
        item.name,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
      subtitle: Text(
        item.content,
        style: TextStyle(color: Colors.white70, fontSize: 14.0),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              item.isStarred ? Icons.star : Icons.star_border,
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
                      hintText: '搜尋',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
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
                  child: Text('新增Prompt'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        '無符合項目',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  // animate lead to error
                  // : AnimatedList(
                  //     key: _listKey,
                  //     initialItemCount: _filteredItems.length,
                  //     itemBuilder: (context, index, animation) {
                  //       return _buildItem(_filteredItems[index], animation, index);
                  //     },
                  //   ),
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return _buildItem(_filteredItems[index], null, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
