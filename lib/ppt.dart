import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chat.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);

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
  final VoidCallback updateMessagesCallback;
  final PdfViewerController pdfViewerController;
  final ValueNotifier<int> currentPageNumber;
  final ValueNotifier<int> totalPageNumber;

  const SlideView({
    Key? key,
    required this.filePath,
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
  List<Map<String, String>> _items = [
    {'title': '生成英文講稿', 'description': '幫我生成英文講稿'},
    {'title': '本堂課程介紹', 'description': '幫我依據這頁的內容生成本堂課的課程介紹'},
    {'title': '生成示意圖', 'description': '幫我依據這頁的內容生成示意圖'},
    {'title': '產生隨堂測驗', 'description': '幫我依據這頁的內容產生隨堂測驗'},
    {'title': '指定文字風格、語氣', 'description': '幫我用...的文字風格來生成英文講稿'},
    {'title': '生成英文講稿', 'description': '幫我生成英文講稿'},
    {'title': '本堂課程介紹', 'description': '幫我依據這頁的內容生成本堂課的課程介紹'},
    {'title': '生成示意圖', 'description': '幫我依據這頁的內容生成示意圖'},
    {'title': '產生隨堂測驗', 'description': '幫我依據這頁的內容產生隨堂測驗'},
    {'title': '指定文字風格、語氣', 'description': '幫我用...的文字風格來生成英文講稿'},
  ];

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0; //  If using AppBar, subtract its height
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final textFieldRenderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
      final textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);
      final textFieldHeight = textFieldRenderBox.size.height;
      final availableSpaceAbove = textFieldOffset.dy - statusBarHeight - appBarHeight;
      final availableSpaceBelow = screenHeight - textFieldOffset.dy - textFieldHeight;
      const int maxVisibleItems = 8;
      final double listItemHeight = 65.0;
      final double listHeight = min(_items.length * listItemHeight, maxVisibleItems * listItemHeight);
      // Determine if the overlay should appear above or below the TextField
      final bool shouldShowAbove = listHeight > availableSpaceBelow && listHeight < availableSpaceAbove;
      double overlayTop;
      double overlayHeight;
      if (shouldShowAbove) {
        // Show above TextField
        overlayHeight = min(listHeight, availableSpaceAbove);
        overlayTop = textFieldOffset.dy - overlayHeight;
      } else {
        // Show below TextField
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
                  child: ClipRRect( // Apply ClipRRect here to include the Material widget
                    borderRadius: BorderRadius.circular(10.0), // Ensure this matches the inner ClipRRect
                    child: Material(
                      elevation: 4.0,
                      color: primaryColor, // Make Material widget transparent
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), // Keep this for inner content
                        child: Container(
                          height: overlayHeight,
                          color: Colors.transparent,
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return Container(
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(_items[index]['title']!, style: TextStyle(color: Colors.white)),
                                  subtitle: Text(_items[index]['description']!, style: TextStyle(color: Colors.white70)),
                                  onTap: () {
                                    setState(() {
                                      _controller.text += " ${_items[index]['description']}";
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
    } else {
      _removeOverlay();
    }
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
      });
      widget.updateMessagesCallback();
    }
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
                      padding: EdgeInsets.only(left: 8.0), // Adjust the padding value as needed
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.lightbulb, size: 25.0, color: Colors.white),
                        onPressed: _toggleOverlay, // Method to open list of items
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8.0), // Adjust the padding value as needed
                      child: IconButton(
                        icon: Icon(FontAwesomeIcons.paperPlane, size: 20.0, color: Colors.white),
                        onPressed: _sendMessage, // Method to send message
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