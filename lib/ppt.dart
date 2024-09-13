import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
const double textSize = 20.0;

List<Widget> messages = [
  ChatMessage(
    message: "您好，需要什麼幫助呢？",
    isSentByMe: false,
  ),
  ChatMessage(
    message: "測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD測試RWD",
    isSentByMe: false,
  ),
];

class PptPage extends StatefulWidget {
  final String filePath;
  const PptPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PptPageState createState() => _PptPageState();
}

class _PptPageState extends State<PptPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final ValueNotifier<int> _currentPageNumber = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPageNumber = ValueNotifier<int>(0);
  final ScrollController _scrollController = ScrollController();
  bool _isFullScreen = false;
  bool _isChatSidebarOpen = true;
  bool _isChatSidebarFullScreen = false; 

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _toggleChatSidebar() {
    setState(() {
      _isChatSidebarOpen = !_isChatSidebarOpen;
    });
  }

  void _toggleChatSidebarFullScreen() {
    setState(() {
      _isChatSidebarFullScreen = !_isChatSidebarFullScreen;
    });
  }

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
              updateMessagesCallback: _updateMessages,
              pdfViewerController: _pdfViewerController,
              currentPageNumber: _currentPageNumber,
              totalPageNumber: _totalPageNumber,
              scrollToBottomCallback: _scrollToBottom,
              scrollController: _scrollController,
              toggleFullScreenCallback: _toggleFullScreen, // Pass the callback
              isFullScreen: _isFullScreen, // Pass the fullscreen state
              isChatSidebarOpen: _isChatSidebarOpen, // Pass the chat sidebar state
              toggleChatSidebarCallback: _toggleChatSidebar,
            ),
          ),
          if (_isChatSidebarOpen && !_isFullScreen)
          Expanded(
            flex: _isChatSidebarFullScreen ? 3 : 1,
            child: ChatSidebar(
              scrollToBottomCallback: _scrollToBottom,
              scrollController: _scrollController,
              toggleChatSidebarFullScreenCallback: _toggleChatSidebarFullScreen,
              closeChatSidebarCallback: _toggleChatSidebar,
              isFullScreen: _isChatSidebarFullScreen,
            ),
          ),
        ],
      ),
    );
  }

  void _updateMessages() {
    setState(() {});
    _scrollToBottom();
  }
}

class SlideView extends StatefulWidget {
  final String filePath;
  final VoidCallback updateMessagesCallback;
  final PdfViewerController pdfViewerController;
  final ValueNotifier<int> currentPageNumber;
  final ValueNotifier<int> totalPageNumber;
  final VoidCallback scrollToBottomCallback;
  final ScrollController scrollController;
  final VoidCallback toggleChatSidebarCallback;
  final VoidCallback toggleFullScreenCallback; // Add this line
  final bool isFullScreen; // Add this line
  final bool isChatSidebarOpen;

  const SlideView({
    Key? key,
    required this.filePath,
    required this.updateMessagesCallback,
    required this.pdfViewerController,
    required this.currentPageNumber,
    required this.totalPageNumber,
    required this.scrollToBottomCallback,
    required this.scrollController,
    required this.isFullScreen, // Add this line
    required this.isChatSidebarOpen, // Add this linee
    required this.toggleFullScreenCallback, // Add this line
    required this.toggleChatSidebarCallback,
  }) : super(key: key);

  @override
  _SlideViewState createState() => _SlideViewState();
}

class _SlideViewState extends State<SlideView> {
  final TextEditingController _controller = TextEditingController();
  GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<Map<String, String>> _items = [
    {'title': '/生成英文講稿', 'description': '幫我生成英文講稿'},
    {'title': '/本堂課程介紹', 'description': '幫我依據這頁的內容生成本堂課的課程介紹'},
    {'title': '/生成示意圖', 'description': '幫我依據這頁的內容生成示意圖'},
    {'title': '/產生隨堂測驗', 'description': '幫我依據這頁的內容產生隨堂測驗'},
    {'title': '/指定文字風格、語氣', 'description': '幫我用...的文字風格來生成英文講稿'},
    {'title': '/生成英文講稿', 'description': '幫我生成英文講稿'},
    {'title': '/本堂課程介紹', 'description': '幫我依據這頁的內容生成本堂課的課程介紹'},
    {'title': '/生成示意圖', 'description': '幫我依據這頁的內容生成示意圖'},
    {'title': '/產生隨堂測驗', 'description': '幫我依據這頁的內容產生隨堂測驗'},
    {'title': '指定文字風格、語氣', 'description': '幫我用...的文字風格來生成英文講稿'},
  ];
  List<Map<String, String>> _filteredItems = [];
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // Add a listener for the 'Esc' key
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    // Remove the listener for the 'Esc' key
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (widget.isFullScreen) {
        widget.toggleFullScreenCallback();
        return true; // Indicate that the event was handled
      }
    }
    return false; // Indicate that the event was not handled
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    final queryAfterSlash = query.contains('/') ? query.split('/').last : query;
    _filteredItems = _items.where((item) {
      final title = item['title']!.toLowerCase();
      final description = item['description']!.toLowerCase();
      return title.contains(queryAfterSlash) || description.contains(queryAfterSlash);
    }).toList();
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
                                title: Text(_filteredItems[index]['title']!, style: TextStyle(color: Colors.white, fontSize: textSize)),
                                subtitle: Text(_filteredItems[index]['description']!, style: TextStyle(color: Colors.white70, fontSize: textSize)),
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

  void _sendMessage() {
    final String text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(message: text, isSentByMe: true));
        _controller.clear();
        _isSent = true;
      });
      widget.updateMessagesCallback();
      widget.scrollToBottomCallback();

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isSent = false;
        });
      });
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
        Row(
          children: [
            if (!widget.isFullScreen)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            if (!widget.isFullScreen && !widget.isChatSidebarOpen)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.chat, color: Colors.white, size: 30),
                  onPressed: widget.toggleChatSidebarCallback,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: SfPdfViewer.file(
                    File(widget.filePath),
                    controller: widget.pdfViewerController,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    onPageChanged: (PdfPageChangedDetails details) {
                      widget.currentPageNumber.value = details.newPageNumber;
                    },
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      widget.totalPageNumber.value = details.document.pages.count;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!widget.isFullScreen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    widget.pdfViewerController.previousPage();
                  },
                ),
                ValueListenableBuilder<int>(
                  valueListenable: widget.currentPageNumber,
                  builder: (context, currentPage, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: widget.totalPageNumber,
                      builder: (context, totalPage, child) {
                        return Row(
                          children: [
                            Text(
                              '$currentPage / $totalPage',
                              style: TextStyle(fontSize: textSize, color: Colors.white),
                            ),
                            IconButton(
                              icon: Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: () {
                                widget.toggleFullScreenCallback();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Esc鍵可退出全螢幕')),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    widget.pdfViewerController.nextPage();
                  },
                ),
              ],
            ),
          ),
        if (!widget.isFullScreen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    key: _textFieldKey,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type '/' to search prompts",
                      hintStyle: TextStyle(color: Colors.white, fontSize: textSize),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.lightbulb, size: 25.0, color: Colors.white),
                          onPressed: _lightbulbPressed,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: _sendMessage,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(child: child, scale: animation);
                            },
                            child: _isSent
                                ? Icon(Icons.check_circle, key: ValueKey<int>(1), size: 20.0, color: Colors.white)
                                : Icon(FontAwesomeIcons.paperPlane, key: ValueKey<int>(0), size: 20.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: textSize),
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


class ChatSidebar extends StatefulWidget {
  final VoidCallback scrollToBottomCallback;
  final ScrollController scrollController;
  final VoidCallback toggleChatSidebarFullScreenCallback; // Add this line
  final VoidCallback closeChatSidebarCallback; // Add this line
  final bool isFullScreen; // Add this line

  ChatSidebar({
    required this.scrollToBottomCallback,
    required this.scrollController,
    required this.toggleChatSidebarFullScreenCallback, // Add this line
    required this.closeChatSidebarCallback, // Add this line
    required this.isFullScreen, // Add this line
  });

  @override
  _ChatSidebarState createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {

  void _resetConversation() {
    setState(() {
      messages.clear();
      messages = [
        ChatMessage(
          message: "Hi, how can I help you?",
          isSentByMe: false,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thickness: 6.0,
              radius: Radius.circular(10),
              controller: widget.scrollController,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                              onPressed: widget.toggleChatSidebarFullScreenCallback,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Assistant',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_comment_outlined, color: Colors.white, size: 20),
                              onPressed: _resetConversation,
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: widget.closeChatSidebarCallback,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: widget.scrollController,
                          padding: EdgeInsets.all(10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) => messages[index],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  final String message;
  final bool isSentByMe;

  ChatMessage({required this.message, required this.isSentByMe});

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  String selectedText = "";

  void _handleSelectionChange(TextSelection selection, SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.longPress || cause == SelectionChangedCause.drag) {
      setState(() {
        selectedText = widget.message.substring(selection.start, selection.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget messageWidget = Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.isSentByMe ? Color.fromARGB(255, 120, 120, 120): Color.fromARGB(255, 80, 80, 80),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SelectableText(
        widget.message,
        style: TextStyle(fontSize: textSize, color: Colors.white),
        onSelectionChanged: _handleSelectionChange,
      ),
    );

    if (!widget.isSentByMe) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: messageWidget,
            ),
            IconButton(
              icon: Icon(Icons.volume_up_rounded, size: 20, color: Colors.white),
              onPressed: () {
                print('Selected text: $selectedText');
              },
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.delete, size: 20, color: Colors.white),
            onPressed: () {
              print('delete message: ${widget.message}');
            },
          ),
          Flexible(
            child: messageWidget,
          ),
        ],
      ),
    );
  }
}