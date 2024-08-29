import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'api_tts.dart' as apiTTS;

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
Map<int, List<Widget>> messagesByPage = {};
List<Widget> messages = [
  
];

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
            Expanded(
              child: messageWidget,
            ),
            IconButton(
              icon: Icon(Icons.volume_up_rounded, size: 30, color: Colors.white),
              onPressed: () {
                // Print the selected text when the volume_up button is clicked
                print('Selected text: $selectedText');
                apiTTS.GptTTS.streamedAudio(selectedText);
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