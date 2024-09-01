import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chat.dart';
import 'api_prompt.dart' as ApiPrompt;
import 'api_gpt.dart' as ApiGpt;

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);

class PptPage extends StatefulWidget {
  final String filePath;
  final int pptId;

  const PptPage({Key? key, required this.filePath, required this.pptId}) : super(key: key);

  @override
  _PptPageState createState() => _PptPageState();
}

class _PptPageState extends State<PptPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final ValueNotifier<int> _currentPageNumber = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPageNumber = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: SlideView(
              filePath: widget.filePath,
              pptId: widget.pptId,
              updateMessagesCallback: _updateMessages,
              pdfViewerController: _pdfViewerController,
              currentPageNumber: _currentPageNumber,
              totalPageNumber: _totalPageNumber,
            ),
          ),
          Expanded(
            flex: 1,
            child: ChatSidebar(),
          ),
        ],
      ),
    );
  }

  void _updateMessages() {
    setState(() {});
  }
}

class SlideView extends StatefulWidget {
  final String filePath;
  final int pptId;
  final VoidCallback updateMessagesCallback;
  final PdfViewerController pdfViewerController;
  final ValueNotifier<int> currentPageNumber;
  final ValueNotifier<int> totalPageNumber;

  const SlideView({
    Key? key,
    required this.filePath,
    required this.pptId,
    required this.updateMessagesCallback,
    required this.pdfViewerController,
    required this.currentPageNumber,
    required this.totalPageNumber,
  }) : super(key: key);

  @override
  _SlideViewState createState() => _SlideViewState();
}

class _SlideViewState extends State<SlideView> {
  final TextEditingController _controller = TextEditingController();
  GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<Map<String, String>> _items  = [];
  List<Map<String, String>> _filteredItems = [];
  int _previousPageNumber = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    fetchPrompts(); // 加載 API 數據
    fetchChat(widget.currentPageNumber.value, widget.pptId);
  }

  Future<void> fetchChat(int page, int ppt_id) async {
  try {
    messages.clear();
    List<Map<String, dynamic>> jsonResponse = await ApiGpt.ApiService.fetchModels(page, ppt_id);
    if (jsonResponse.isEmpty) {      
      messages.add(
        ChatMessage(
          message: "Hello, how can I assist you?",
          isSentByMe: false,
        )
      );
    }
    for (var item in jsonResponse) {
      messages.add(ChatMessage(
        message: item['pptword_question'],
        isSentByMe: true,
      ));
      messages.add(ChatMessage(
        message: item['pptword_content'],
        isSentByMe: false,
      ));
    }

    widget.updateMessagesCallback();
  } catch (e) {
    print('Failed to load chat: $e');
  }
}


  Future<void> fetchPrompts() async {
    try {
      List<ApiPrompt.Prompt> prompts = await ApiPrompt.ApiService.fetchModels();
      setState(() {
        _filteredItems = prompts.map((prompt) {
          return {
            'title': prompt.name,
            'description': prompt.content,
            'id': prompt.prompt_id.toString(),
          };
        }).toList();
        _items = _filteredItems; // 初始化 _items 為獲取到的數據
      });
    } catch (e) {
      print('Failed to load prompts: $e');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    final queryAfterSlash = query.contains('/') ? query.split('/').last : query;

    setState(() {
      _filteredItems = _items.where((item) {
        final title = item['title']!.toLowerCase();
        final description = item['description']!.toLowerCase();
        return title.contains(queryAfterSlash) || description.contains(queryAfterSlash);
      }).toList();
    });
    _toggleOverlay();
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final textFieldRenderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);
    final textFieldHeight = textFieldRenderBox.size.height;
    final availableSpaceAbove = textFieldOffset.dy - statusBarHeight - appBarHeight;
    final availableSpaceBelow = screenHeight - textFieldOffset.dy - textFieldHeight;
    const int maxVisibleItems = 6;
    final double listItemHeight = 65.0;
    final double listHeight = min(_filteredItems.length * listItemHeight, maxVisibleItems * listItemHeight);
    final bool shouldShowAbove = listHeight > availableSpaceBelow && listHeight < availableSpaceAbove;
    double overlayTop;
    double overlayHeight;

    if (shouldShowAbove) {
      overlayHeight = min(listHeight, availableSpaceAbove);
      overlayTop = textFieldOffset.dy - overlayHeight;
    } else {
      overlayHeight = min(listHeight, availableSpaceBelow);
      overlayTop = textFieldOffset.dy + textFieldHeight;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: overlayTop,
                left: textFieldOffset.dx,
                width: textFieldRenderBox.size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Material(
                    elevation: 4.0,
                    color: primaryColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        height: overlayHeight,
                        color: Colors.transparent,
                        child: ListView.builder(
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.transparent,
                              child: ListTile(
                                title: Text(_filteredItems[index]['title']!, style: TextStyle(color: Colors.white)),
                                subtitle: Text(_filteredItems[index]['description']!, style: TextStyle(color: Colors.white70)),
                                onTap: () {
                                  setState(() {
                                    final text = _controller.text;
                                    final lastSlashIndex = text.lastIndexOf('/');
                                    final textBeforeLastSlash = lastSlashIndex != -1 ? text.substring(0, lastSlashIndex) : text;
                                    _controller.text = "$textBeforeLastSlash${_filteredItems[index]['description']} ";
                                    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
                                  });
                                  _removeOverlay();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _sendMessage() async {
    final String text = _controller.text;    
    if (text.isNotEmpty) {
      setState(() {
        // 先將用戶輸入的訊息加入 messages
        messages.add(ChatMessage(message: text, isSentByMe: true));
        print("send messages to chat ...");
        _controller.clear();  // 清除輸入框
        _removeOverlay();     // 清除彈出層
        // 更新消息回調
        widget.updateMessagesCallback();
      });

      try {
        // 使用 await 等待 sendMessage 完成，並獲取返回值
        String returnText = await ApiGpt.ApiService.sendMessage(text, widget.currentPageNumber.value, widget.pptId);
        
        setState(() {
          // 將返回的訊息加入 messages
          messages.add(ChatMessage(message: returnText, isSentByMe: false));
        });
        
        // 更新消息回調
        widget.updateMessagesCallback();
      } catch (e) {
        // 異常處理
        print('Error sending message: $e');
      }
    }
  }


  void _lightbulbPressed() {
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    _filteredItems = _items;
    _toggleOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: Container(
            color: backgroundColor,
            child: SfPdfViewer.file(
              File(widget.filePath),
              controller: widget.pdfViewerController,
              pageLayoutMode: PdfPageLayoutMode.single,
              onPageChanged: (PdfPageChangedDetails details) {
                // detect page change
                if (details.newPageNumber > _previousPageNumber) {
                  // print("next page by wheel");
                  fetchChat(details.newPageNumber, widget.pptId);
                } else if (details.newPageNumber < _previousPageNumber) {
                  // print("last page by wheel");
                  fetchChat(details.newPageNumber, widget.pptId);
                }
                _previousPageNumber = details.newPageNumber;
                widget.currentPageNumber.value = details.newPageNumber;
              },
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                widget.totalPageNumber.value = details.document.pages.count;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // fetchChat(widget.currentPageNumber.value - 1, widget.pptId);
                  widget.pdfViewerController.previousPage();                  
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: widget.currentPageNumber,
                builder: (context, currentPage, child) {
                  return ValueListenableBuilder<int>(
                    valueListenable: widget.totalPageNumber,
                    builder: (context, totalPage, child) {
                      return Text(
                        '$currentPage / $totalPage',
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  // fetchChat(widget.currentPageNumber.value + 1, widget.pptId);
                  widget.pdfViewerController.nextPage();                  
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: _textFieldKey,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Type your prompt...",
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.lightbulb, size: 25.0, color: Colors.white),
                        onPressed: _lightbulbPressed,
                      ),
                    ),
                    suffixIcon: Padding(  // send message button
                      padding: EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.paperPlane, size: 20.0, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onSubmitted: (value) {
                    _sendMessage();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}