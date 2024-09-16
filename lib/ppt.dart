import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
// import 'chat.dart';
import 'api_prompt.dart' as ApiPrompt;
import 'api_gpt.dart' as ApiGPT;
import 'api_tts.dart' as ApiTTS;
import 'personal.dart';

// const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
const double textSize = 20.0;

// Define the ChatMessageData class
class ChatMessageData {
  final String message;
  final bool isSentByMe;
  int? pptword_id;
  int? pptword_page;
  int? ppt_id;

  ChatMessageData({
    required this.message,
    required this.isSentByMe,
    this.pptword_id,
    this.pptword_page,
    this.ppt_id,
  });
}

// Update the messages list to hold ChatMessageData objects
List<ChatMessageData> messages = [];

class PptPage extends StatefulWidget {
  final String filePath;
  final int pptId;
  final int userId;

  const PptPage({
    Key? key,
    required this.filePath,
    required this.pptId,
    required this.userId,
  }) : super(key: key);

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

  // Create a GlobalKey to access SlideView state
  final GlobalKey<_SlideViewState> slideViewKey = GlobalKey<_SlideViewState>();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), // Add animation time
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

  void deleteChatMessage(int pptword_id, int pptword_page, int ppt_id) {
    slideViewKey.currentState
        ?.deleteChatMessage(pptword_id, pptword_page, ppt_id);
  }

  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.pptBackgroundColor,
      body: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: SlideView(
              key: slideViewKey, // Pass the GlobalKey
              filePath: widget.filePath,
              pptId: widget.pptId,
              updateMessagesCallback: _updateMessages,
              pdfViewerController: _pdfViewerController,
              currentPageNumber: _currentPageNumber,
              totalPageNumber: _totalPageNumber,
              scrollToBottomCallback: _scrollToBottom,
              scrollController: _scrollController,
              toggleFullScreenCallback: _toggleFullScreen,
              isFullScreen: _isFullScreen,
              isChatSidebarOpen: _isChatSidebarOpen,
              toggleChatSidebarCallback: _toggleChatSidebar,
              userId: widget.userId,
            ),
          ),
          if (_isChatSidebarOpen && !_isFullScreen)
            Expanded(
              flex: _isChatSidebarFullScreen ? 3 : 1,
              child: ChatSidebar(
                scrollToBottomCallback: _scrollToBottom,
                scrollController: _scrollController,
                toggleChatSidebarFullScreenCallback:
                    _toggleChatSidebarFullScreen,
                closeChatSidebarCallback: _toggleChatSidebar,
                isFullScreen: _isChatSidebarFullScreen,
                deleteChatMessageCallback: deleteChatMessage, // Pass the callback
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
  final int pptId;
  final VoidCallback updateMessagesCallback;
  final PdfViewerController pdfViewerController;
  final ValueNotifier<int> currentPageNumber;
  final ValueNotifier<int> totalPageNumber;
  final VoidCallback scrollToBottomCallback;
  final ScrollController scrollController;
  final VoidCallback toggleChatSidebarCallback;
  final VoidCallback toggleFullScreenCallback;
  final bool isFullScreen;
  final bool isChatSidebarOpen;
  final int userId;

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
    required this.isFullScreen,
    required this.isChatSidebarOpen,
    required this.toggleFullScreenCallback,
    required this.toggleChatSidebarCallback,
    required this.userId,
  }) : super(key: key);

  @override
  _SlideViewState createState() => _SlideViewState();
}

class _SlideViewState extends State<SlideView> {
  final TextEditingController _controller = TextEditingController();
  GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<Map<String, String>> _items = [];
  List<Map<String, String>> _filteredItems = [];
  int _previousPageNumber = 1;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    fetchPrompts();
    fetchChat(widget.currentPageNumber.value, widget.pptId);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (widget.isFullScreen) {
        widget.toggleFullScreenCallback();
        return true;
      }
    }
    return false;
  }

  Future<void> fetchChat(int page, int ppt_id) async {
    try {
      messages.clear();
      List<Map<String, dynamic>> jsonResponse =
          await ApiGPT.ApiService.fetchModels(page, ppt_id);

      if (jsonResponse.isEmpty) {
        messages.add(ChatMessageData(
          message: "Hello, how can I help you?",
          isSentByMe: false,
        ));
      }

      for (var item in jsonResponse) {
        messages.add(ChatMessageData(
          message: item['pptword_question'],
          isSentByMe: true,
          pptword_id: item['pptword_id'],
          pptword_page: item['pptword_page'],
          ppt_id: item['ppt_ppt'],
        ));
        messages.add(ChatMessageData(
          message: item['pptword_content'],
          isSentByMe: false,
        ));
      }

      widget.updateMessagesCallback();

      Future.delayed(Duration(milliseconds: 500), () {
        widget.scrollToBottomCallback();
      });
    } catch (e) {
      print('Failed to load chat: $e');
    }
  }

  Future<void> fetchPrompts() async {
    try {
      List<ApiPrompt.Prompt> prompts =
          await ApiPrompt.ApiService.fetchModels(widget.userId);
      setState(() {
        _filteredItems = prompts.map((prompt) {
          return {
            'title': prompt.name,
            'description': prompt.content,
            'id': prompt.prompt_id.toString(),
          };
        }).toList();
        _items = _filteredItems;
      });
    } catch (e) {
      print('Failed to load prompts: $e');
    }
  }

  void deleteChatMessage(int pptword_id, int pptword_page, int ppt_id) async {
    try {
      final response = await ApiGPT.ApiService.deleteChat(pptword_id);
      if (response.statusCode == 204) {
        await fetchChat(pptword_page, ppt_id);
      }
    } catch (e) {
      print('Failed to delete message: $e');
    }
  }

  void deletePageChatMessage(int pptword_page, int ppt_id) async {
    // try {
    //   final response = await ApiGPT.ApiService.deleteChatByPage(pptword_page, ppt_id);
    //   if (response.statusCode == 204) {
    //     await fetchChat(pptword_page, ppt_id);
    //   }
    // } catch (e) {
    //   print('Failed to delete message: $e');
    // }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    final queryAfterSlash =
        query.contains('/') ? query.split('/').last : query;

    setState(() {
      _filteredItems = _items.where((item) {
        final title = item['title']!.toLowerCase();
        final description = item['description']!.toLowerCase();
        return title.contains(queryAfterSlash) ||
            description.contains(queryAfterSlash);
      }).toList();
    });
    _toggleOverlay();
  }

  void _toggleOverlay() {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final textFieldRenderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);
    final textFieldHeight = textFieldRenderBox.size.height;
    final availableSpaceAbove =
        textFieldOffset.dy - statusBarHeight - appBarHeight;
    final availableSpaceBelow =
        screenHeight - textFieldOffset.dy - textFieldHeight;
    const int maxVisibleItems = 6;
    final double listItemHeight = 65.0;
    final double listHeight =
        min(_filteredItems.length * listItemHeight, maxVisibleItems * listItemHeight);
    final bool shouldShowAbove =
        listHeight > availableSpaceBelow && listHeight < availableSpaceAbove;
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
                    color: themeProvider.chatBackgroundColor,
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
                                title: Text(
                                  _filteredItems[index]['title']!,
                                  style: TextStyle(
                                      color: themeProvider.quaternaryColor,
                                      fontSize: textSize),
                                ),
                                subtitle: Text(
                                  _filteredItems[index]['description']!,
                                  style: TextStyle(
                                      color: themeProvider.tertiaryColor,
                                      fontSize: textSize),
                                ),
                                onTap: () {
                                  setState(() {
                                    final text = _controller.text;
                                    final lastSlashIndex =
                                        text.lastIndexOf('/');
                                    final textBeforeLastSlash =
                                        lastSlashIndex != -1
                                            ? text.substring(0, lastSlashIndex)
                                            : text;
                                    _controller.text =
                                        "$textBeforeLastSlash${_filteredItems[index]['description']} ";
                                    _controller.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: _controller.text.length));
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
        messages.add(ChatMessageData(
          message: text,
          isSentByMe: true,
        ));
        _controller.clear();
        _isSent = true;
        _removeOverlay();
        widget.updateMessagesCallback();
        widget.scrollToBottomCallback();
      });

      try {
        String returnText = await ApiGPT.ApiService.sendMessage(
            text, widget.currentPageNumber.value, widget.pptId);

        setState(() {
          messages.add(ChatMessageData(
            message: returnText,
            isSentByMe: false,
          ));
          _isSent = false;
        });

        widget.updateMessagesCallback();
      } catch (e) {
        print('Error sending message: $e');
        setState(() {
          _isSent = false;
        });
      } finally {
        fetchChat(widget.currentPageNumber.value, widget.pptId);
      }
    }
  }

  void _lightbulbPressed() {
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    _filteredItems = _items;
    _toggleOverlay();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
                    icon: Icon(Icons.arrow_back,
                        color: themeProvider.quaternaryColor, size: 30),
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
                    icon: Icon(Icons.chat,
                        color: themeProvider.quaternaryColor, size: 30),
                    onPressed: widget.toggleChatSidebarCallback,
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Container(
            // color: themeProvider.primaryColor,
            child: SfPdfViewerTheme(
              data: SfPdfViewerThemeData(
                backgroundColor: themeProvider.pptViewBackgroundColor, // 您可以使用任何您需要的颜色
              ),
              child: SfPdfViewer.file(
                File(widget.filePath),
                controller: widget.pdfViewerController,
                pageLayoutMode: PdfPageLayoutMode.single,
                onPageChanged: (PdfPageChangedDetails details) {
                  // 更新页码
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
        ),
        if (!widget.isFullScreen)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: themeProvider.quaternaryColor),
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
                              style: TextStyle(
                                  fontSize: textSize,
                                  color: themeProvider.quaternaryColor),
                            ),
                            IconButton(
                              icon: Icon(Icons.fullscreen,
                                  color: themeProvider.quaternaryColor),
                              onPressed: () {
                                widget.toggleFullScreenCallback();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Press Esc to exit fullscreen')),
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
                  icon: Icon(Icons.arrow_forward,
                      color: themeProvider.quaternaryColor),
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
                      hintStyle: TextStyle(
                          color: themeProvider.chatPromptTextColor,
                          fontSize: textSize),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.lightbulb,
                              size: 25.0, color: themeProvider.quaternaryColor),
                          onPressed: _lightbulbPressed,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: _sendMessage,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  child: child, scale: animation);
                            },
                            child: _isSent
                                ? Icon(Icons.check_circle,
                                    key: ValueKey<int>(1),
                                    size: 20.0,
                                    color: themeProvider.quaternaryColor)
                                : Icon(FontAwesomeIcons.paperPlane,
                                    key: ValueKey<int>(0),
                                    size: 20.0,
                                    color: themeProvider.quaternaryColor),
                          ),
                        ),
                      ),
                    ),
                    style: TextStyle(
                        color: themeProvider.tertiaryColor, fontSize: textSize),
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
  final VoidCallback toggleChatSidebarFullScreenCallback;
  final VoidCallback closeChatSidebarCallback;
  final bool isFullScreen;
  final Function(int pptword_id, int pptword_page, int ppt_id)
      deleteChatMessageCallback;

  ChatSidebar({
    required this.scrollToBottomCallback,
    required this.scrollController,
    required this.toggleChatSidebarFullScreenCallback,
    required this.closeChatSidebarCallback,
    required this.isFullScreen,
    required this.deleteChatMessageCallback,
  });

  _ChatSidebarState createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  void _resetConversation() {
    setState(() {
      messages.clear();
      messages = [
        ChatMessageData(
          message: "Hello, how can I help you?",
          isSentByMe: false,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      color: themeProvider.pptBackgroundColor,
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
                    color: themeProvider.chatBackgroundColor,
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
                              icon: Icon(
                                  widget.isFullScreen
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                  color: themeProvider.quaternaryColor),
                              onPressed:
                                  widget.toggleChatSidebarFullScreenCallback,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Assistant',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.tertiaryColor,
                                  ),
                                ),
                              ),
                            ),
                            IconButton( // undo
                              icon: Icon(Icons.add_comment_outlined,
                                  color: themeProvider.quaternaryColor,
                                  size: 20),
                              onPressed: _resetConversation,
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: themeProvider.quaternaryColor),
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
                          itemBuilder: (context, index) {
                            final messageData = messages[index];
                            return ChatMessage(
                              message: messageData.message,
                              isSentByMe: messageData.isSentByMe,
                              pptword_id: messageData.pptword_id,
                              pptword_page: messageData.pptword_page,
                              ppt_id: messageData.ppt_id,
                              onDeleteMessage: widget.deleteChatMessageCallback,
                            );
                          },
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
  int? pptword_id;
  int? pptword_page;
  int? ppt_id;
  final Function(int pptword_id, int pptword_page, int ppt_id)? onDeleteMessage;

  ChatMessage({
    required this.message,
    required this.isSentByMe,
    this.pptword_id,
    this.pptword_page,
    this.ppt_id,
    this.onDeleteMessage,
  });

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
        isPlayingAudio = false;
      });
    });
  }

  void _playAudio() {
    setState(() {
      isPlayingAudio = true;
    });

    ApiTTS.GptTTS.playAudio('audio_url', onComplete: () {
      setState(() {
        isPlayingAudio = false;
      });
    });
  }

  void _handleSelectionChange(
      TextSelection selection, SelectionChangedCause? cause) {
    if (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.drag) {
      setState(() {
        selectedText =
            widget.message.substring(selection.start, selection.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Widget messageWidget = Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeProvider.chatMessageColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SelectableText(
        widget.message,
        style: TextStyle(fontSize: 16, color: Colors.white),
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
              icon: Icon(
                isPlayingAudio ? Icons.stop : Icons.volume_up_rounded,
                size: 20,
                color: themeProvider.quaternaryColor,
              ),
              onPressed: () async {
                if (isPlayingAudio) {
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
                  } else {
                    await ApiTTS.GptTTS.streamedAudio(widget.message);
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
      alignment:
          widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.delete,
                size: 20, color: themeProvider.quaternaryColor),
            onPressed: () {
              if (widget.onDeleteMessage != null &&
                  widget.pptword_id != null &&
                  widget.pptword_page != null &&
                  widget.ppt_id != null) {
                widget.onDeleteMessage!(
                  widget.pptword_id!,
                  widget.pptword_page!,
                  widget.ppt_id!,
                );
              } else {
                print('Cannot delete message: missing ids');
              }
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
