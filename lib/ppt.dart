import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
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
  const PptPage({super.key});

  @override
  _PptPageState createState() => _PptPageState();
}

class _PptPageState extends State<PptPage> {
  void _updateMessages() {
    setState(() {});
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
              updateMessagesCallback: _updateMessages,
            ),
          ),
          // VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            flex: 1,
            child: ChatSidebar(),
          ),
        ],
      ),
    );
  }
}


class SlideView extends StatefulWidget {
  final VoidCallback updateMessagesCallback;

  const SlideView({Key? key, required this.updateMessagesCallback}) : super(key: key);


  @override
  _SlideViewState createState() => _SlideViewState();
}

class _SlideViewState extends State<SlideView> {
  final TextEditingController _controller = TextEditingController();
  GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<String> _items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"];
  int hoveredIndex = -1;

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 0; // If using AppBar, subtract its height
      final statusBarHeight = MediaQuery.of(context).padding.top;

      final textFieldRenderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
      final textFieldOffset = textFieldRenderBox.localToGlobal(Offset.zero);
      final textFieldHeight = textFieldRenderBox.size.height;

      final availableSpaceAbove = textFieldOffset.dy - statusBarHeight - appBarHeight;
      final availableSpaceBelow = screenHeight - textFieldOffset.dy - textFieldHeight;

      const int maxVisibleItems = 8;
      final double listItemHeight = 50.0; // Assuming each list item has a fixed height of 50.0
      final double listHeight = min(_items.length, maxVisibleItems) * listItemHeight;

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
                                  title: Text(_items[index], style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    // Append the tapped item's text to the TextField's current text
                                    setState(() {
                                      _controller.text += " ${_items[index]}"; // Append the item text
                                      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length)); // Move cursor to the end
                                    });
                                    _removeOverlay(); // Optionally close the overlay after selection
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

  // Method to calculate the left position of the overlay to align with the TextField
  double _calculateOverlayLeftPosition() {
    final RenderBox renderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    return offset.dx; // Return the left position for the overlay
  }

  // Method to calculate the width of the overlay to match the TextField
  double _calculateOverlayWidth() {
    final RenderBox renderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.width; // Return the width of the TextField
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _calculateOverlayPosition() {
    final RenderBox renderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Return the top position for the overlay, adjust based on your UI
    return offset.dy - 210; // Example: TextField's Y position - Overlay Height
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
            child: Center(
              child: Text(
                'Slide Content Here',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              Text('2 / 36'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {},
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


class ChatSidebar extends StatefulWidget {
  @override
  _ChatSidebarState createState() => _ChatSidebarState();
}

class _ChatSidebarState extends State<ChatSidebar> {
  final ScrollController _scrollController = ScrollController(); // Step 1: Declare ScrollController

  @override
  void initState() {
    super.initState();
    // Initialize your ScrollController here if needed
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 48, 48, 48),
      child: Scrollbar(
        thickness: 6.0,
        radius: Radius.circular(10),
        controller: _scrollController, // Connect the Scrollbar to the ScrollController
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Step 4: Assign the ScrollController to ListView.builder
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) => messages[index],
              ),
            ),
          ],
        ),
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
        color: widget.isSentByMe ? backgroundColor : Color.fromARGB(255, 80, 80, 80),
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
            Expanded(
              child: messageWidget,
            ),
            IconButton(
              icon: Icon(Icons.volume_up_rounded, size: 30, color: Colors.white),
              onPressed: () {
                // Print the selected text when the volume_up button is clicked
                print('Selected text: $selectedText');
              },
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: widget.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: messageWidget,
    );
  }
}