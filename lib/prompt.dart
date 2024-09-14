import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_prompt.dart';
import 'personal.dart';

// const Color backgroundColor = Color.fromARGB(255, 249, 247, 247);
const double textSize = 20.0;

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
      print('Failed to fetchPrompts: $e');
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
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    TextEditingController titleController = TextEditingController(text: _filteredItems[index].name);
    TextEditingController descriptionController = TextEditingController(text: _filteredItems[index].content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('編輯Prompt',style: TextStyle(color: themeProvider.tertiaryColor, fontSize: textSize)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題', labelStyle: TextStyle(color: themeProvider.tertiaryColor, fontSize: textSize)),
                style: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Prompt描述', labelStyle: TextStyle(color: themeProvider.tertiaryColor, fontSize: textSize)),
                style: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消', style: TextStyle(color: themeProvider.tertiaryColor, fontSize: textSize)),
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
                  print('Failed to editItem: $e');
                }
              },
              child: Text('儲存', style: TextStyle(color: themeProvider.tertiaryColor, fontSize: textSize)),
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
                  print('Failed to addItem: $e');
                }
              },
              child: Text('新增', style: TextStyle(fontSize: textSize)),
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
      print('Failed to deleteItem: $e');
    }
    finally{
      _fetchPrompts();
    }
  }

  Widget _buildItem(Prompt item, Animation<double>? animation, int index) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Widget listItem = ListTile(
      title: Text(
        item.name,
        style: TextStyle(color: Color.fromARGB(255, 17, 45, 78), fontSize: textSize),
      ),
      subtitle: Text(
        item.content,
        style: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize - 4),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              item.isStarred ? Icons.star : Icons.star_border,
              color: Color.fromARGB(255, 63, 114, 175),
            ),
            onPressed: () => _starItem(index),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Color.fromARGB(255, 63, 114, 175)),
            onPressed: () => _editItem(index),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Color.fromARGB(255, 63, 114, 175)),
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
      backgroundColor: Colors.white,
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
                      hintStyle: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize),
                      prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 63, 114, 175)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Color.fromARGB(255, 17, 45, 78)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Color.fromARGB(255, 17, 45, 78)),
                      ),
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Color.fromARGB(255, 63, 114, 175), // Background color
                    foregroundColor: Colors.white, // Text color
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
                        style: TextStyle(color: Color.fromARGB(255, 63, 114, 175), fontSize: textSize),
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
