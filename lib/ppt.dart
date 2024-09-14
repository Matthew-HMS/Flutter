import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'chat.dart';
import 'api_prompt.dart' as ApiPrompt;
import 'api_gpt.dart' as ApiGPT;
import 'api_tts.dart' as ApiTTS;
import 'api_gpt.dart' as ApiGPT;

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
const double textSize = 20.0;
Map<int, List<Widget>> messagesByPage = {};
List<Widget> messages = [];

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
  final ScrollController _scrollController = ScrollController(); 
  bool _isFullScreen = false;
  bool _isChatSidebarOpen = true;
  bool _isChatSidebarFullScreen = false; 

  void _scrollToBottom() {
    // print("call _scrollToBottom");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // print(_scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), //add anime time
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
              pptId: widget.pptId,
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
          // !_isFullScreen
          //   ? Expanded(
          //       flex: 1,
          //       child: ChatSidebar(
          //         scrollToBottomCallback: _scrollToBottom,
          //         scrollController: _scrollController,
          //       ),
          //     )
          //   : const SizedBox.shrink()
        ],
      ),
    );
  }

  void _updateMessages() {
    // print("call _updateMessages");
    setState(() {});
    _scrollToBottom();
  }
}

class SlideView extends StatefulWidget {
  final String filePath;
  final int pptId;
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
    required this.pptId,
    required this.updateMessagesCallback,
    required this.pdfViewerController,
    required this.currentPageNumber,
    required this.totalPageNumber,
    required this.scrollToBottomCallback, 
    required this.scrollController,
    // required this.toggleFullScreenCallback, // Add this line
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
  List<Map<String, String>> _items  = [];
  List<Map<String, String>> _filteredItems = [];
  int _previousPageNumber = 1;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // Add a listener for the 'Esc' key
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    fetchPrompts(); // 加載 API 數據
    fetchChat(widget.currentPageNumber.value, widget.pptId);
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

  Future<void> fetchChat(int page, int ppt_id) async {
    // print("call fetch chat");
    try {
      messages.clear();
      List<Map<String, dynamic>> jsonResponse = await ApiGPT.ApiService.fetchModels(page, ppt_id);
      
      if (jsonResponse.isEmpty) {      
        messages.add(ChatMessage(
          message: "Hello, how can I assist you?",
          isSentByMe: false,
        ));
      }

      for (var item in jsonResponse) {
        messages.add(ChatMessage(
          message: item['pptword_question'],
          isSentByMe: true,
          pptword_id: item['pptword_id'],
          pptword_page: item['pptword_page'],
          ppt_id: item['ppt_ppt'],
        ));
        messages.add(ChatMessage(
          message: item['pptword_content'],
          isSentByMe: false,
        ));
      }

      widget.updateMessagesCallback();

      // delay to wait chat load finish
      Future.delayed(Duration(milliseconds: 500), () {
        widget.scrollToBottomCallback();
      });

      // print("end call chat fetch");
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

  void _sendMessage() async {
    final String text = _controller.text;    
    if (text.isNotEmpty) {
      setState(() {
        // 先將用戶輸入的訊息加入 messages
        messages.add(ChatMessage(message: text, isSentByMe: true));
        print("send messages to chat ...");
        _controller.clear();  // 清除輸入框
        _isSent = true;
        _removeOverlay();     // 清除彈出層
        // 更新消息回調
        widget.updateMessagesCallback();
        widget.scrollToBottomCallback();

        // fetchChat(widget.currentPageNumber.value, widget.pptId);
      });

      try {
        // 使用 await 等待 sendMessage 完成，並獲取返回值
        String returnText = await ApiGPT.ApiService.sendMessage(text, widget.currentPageNumber.value, widget.pptId);
        
        setState(() {
          // 將返回的訊息加入 messages
          messages.add(ChatMessage(message: returnText, isSentByMe: false));
          _isSent = false; // API 回應完成後重置動畫
        });
        
        // 更新消息回調
        widget.updateMessagesCallback();
      } catch (e) {
        // 異常處理
        print('Error sending message: $e');
        setState(() {
          _isSent = false; // 出錯後也要重置動畫
        });
      }
      finally {
        fetchChat(widget.currentPageNumber.value, widget.pptId);
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
        // 如果不是全螢幕，顯示返回按鈕
        // if (!widget.isFullScreen)
        //   Container(
        //     padding: EdgeInsets.all(10),
        //     alignment: Alignment.centerLeft,
        //     child: IconButton(
        //       icon: Icon(Icons.arrow_back, color: Colors.blue, size: 30),
        //       onPressed: () => Navigator.of(context).pop(),
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
          // ),
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

        // PDF Viewer 與頁面切換按鈕
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
                      // 更新頁碼
                      if (details.newPageNumber > _previousPageNumber) {
                        fetchChat(details.newPageNumber, widget.pptId);
                      } else if (details.newPageNumber < _previousPageNumber) {
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
            ],
          ),
        ),

        // 如果不是全螢幕，顯示頁碼與全螢幕按鈕
        if (!widget.isFullScreen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.red),
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

        // 如果不是全螢幕，顯示文字輸入框與發送按鈕
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
  // 0902
  final VoidCallback scrollToBottomCallback; // Step 1: Add callback
  final ScrollController scrollController;
  final VoidCallback toggleChatSidebarFullScreenCallback; // Add this line
  final VoidCallback closeChatSidebarCallback; // Add this line
  final bool isFullScreen; // Add this line
  
  // ChatSidebar({required this.scrollToBottomCallback, required this.scrollController});
  //
  ChatSidebar({
    required this.scrollToBottomCallback,
    required this.scrollController,
    required this.toggleChatSidebarFullScreenCallback, // Add this line
    required this.closeChatSidebarCallback, // Add this line
    required this.isFullScreen, // Add this line
  });

  _ChatSidebarState createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  // 0902
  // final ScrollController _scrollController = ScrollController(); // Step 1: Declare ScrollController

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize your ScrollController here if needed
  // }
  //

  // @override
  // void dispose() {    
  //   //0902
  //   // _scrollController.dispose(); // Dispose of the ScrollController
  //   widget.scrollController.dispose();
  //   //
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Color.fromARGB(255, 48, 48, 48),
      // child: Scrollbar(
      //   thickness: 6.0,
      //   radius: Radius.circular(10),
      //   //0902
      //   // controller: _scrollController, // Connect the Scrollbar to the ScrollController
      //   controller: widget.scrollController, // Connect the Scrollbar to the ScrollController
      //   child: Column(
      //     children: <Widget>[
      //       Expanded(
      //         child: ListView.builder(
      //           controller: widget.scrollController, // Step 4: Assign the ScrollController to ListView.builder
      //           padding: EdgeInsets.all(10),
      //           itemCount: messages.isEmpty ? 1 : messages.length,
      //           itemBuilder: (context, index) {
      //             if (messages.isEmpty) {
      //               return Center(child: Text("No messages yet."));
      //             }
      //             return messages[index];
      //           }
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
                              onPressed: (){},
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
        //   ],
        // ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatefulWidget {
  final String message;
  final bool isSentByMe;
  int? pptword_id;
  int? pptword_page;
  int? ppt_id;

  ChatMessage({required this.message, required this.isSentByMe, this.pptword_id, this.pptword_page, this.ppt_id});

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  String selectedText = "";
  bool isPlayingAudio = false;

  void initState() {
    super.initState();
    ApiTTS.GptTTS.setAudioCompleteCallback(() {
      setState(() {
        isPlayingAudio = false; // 更新狀態為停止
      });
    });
  }

  // void deleteChatMessage(int pptword_id, int pptword_page, int ppt_id) async {
  //   try {
  //     final response = await ApiGPT.ApiService.deleteChat(pptword_id);
  //     if (response.statusCode == 204) {
  //       fetchChat(pptword_page,ppt_id);
  //     }           
  //   } catch (e) {
  //     print('Failed to delete PptFile: $e');
  //   }
  //   finally{
  //     fetchChat();
  //   }
  // }

  void _playAudio() {
    setState(() {
      isPlayingAudio = true;
    });

    ApiTTS.GptTTS.playAudio('audio_url', onComplete: () {
      // 當音頻播放完成時，更新 UI 狀態
      setState(() {
        isPlayingAudio = false;
      });
    });
  }

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
        // color: widget.isSentByMe ? backgroundColor : Color.fromARGB(255, 80, 80, 80),
        color: widget.isSentByMe ? Color.fromARGB(255, 120, 120, 120): Color.fromARGB(255, 80, 80, 80),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SelectableText(
        widget.message,
        style: TextStyle(fontSize: 16, color: Colors.white),
        onSelectionChanged: _handleSelectionChange,
      ),
      // child: MarkdownBody(
      //   data: widget.message,
      //   styleSheet: MarkdownStyleSheet(
      //     p: TextStyle(fontSize: 16, color: Colors.white),
      //   ),
      // ),
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
              icon: Icon(
                // ApiTTS.GptTTS.isPlayingAudio() ? Icons.stop : Icons.volume_up_rounded, // 更新圖標根據播放狀態
                isPlayingAudio ? Icons.stop : Icons.volume_up_rounded,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () async {
                if (isPlayingAudio) {
                  // stop playing audio 
                  await ApiTTS.GptTTS.stopAudio();
                  selectedText = "";
                  setState(() {
                    isPlayingAudio = false; 
                  });
                } else {
                  setState(() {
                    isPlayingAudio = true;
                  });

                  if (selectedText.isNotEmpty) {
                    await ApiTTS.GptTTS.streamedAudio(selectedText);
                    print("start playing selected audio");
                  } else {
                    await ApiTTS.GptTTS.streamedAudio(widget.message);
                    print("start playing all audio");
                  }
                  selectedText = "";
                }
              },
            ),
          ],
        ),
      );
    }

    
    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: messageWidget,
      // child: Row(
      //   mainAxisSize: MainAxisSize.min,
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     IconButton(
      //       icon: Icon(Icons.delete, size: 20, color: Colors.white),
      //       onPressed: () {
      //         // Print the selected text when the volume_up button is clicked
      //         print('delete message: ${widget.pptword_id}, page: ${widget.pptword_page}, ppt_id: ${widget.ppt_id}');
      //       },
      //     ),
      //     Flexible(
      //       child: messageWidget,
      //     ),
      //   ],
      // ),
    );
  }
}