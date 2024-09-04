import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'api_tts.dart' as apiTTS;

const Color backgroundColor = Color.fromARGB(255, 61, 61, 61);
const Color primaryColor = Color.fromARGB(255, 48, 48, 48);
Map<int, List<Widget>> messagesByPage = {};
List<Widget> messages = [];

class ChatSidebar extends StatefulWidget {

  // 0902
  final VoidCallback scrollToBottomCallback; // Step 1: Add callback
  final ScrollController scrollController;
  ChatSidebar({required this.scrollToBottomCallback, required this.scrollController});
  //

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

  @override
  void dispose() {
    
    //0902
    // _scrollController.dispose(); // Dispose of the ScrollController
    widget.scrollController.dispose();
    //

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 48, 48, 48),
      child: Scrollbar(
        thickness: 6.0,
        radius: Radius.circular(10),
        //0902
        // controller: _scrollController, // Connect the Scrollbar to the ScrollController
        controller: widget.scrollController, // Connect the Scrollbar to the ScrollController
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController, // Step 4: Assign the ScrollController to ListView.builder
                padding: EdgeInsets.all(10),
                itemCount: messages.isEmpty ? 1 : messages.length,
                itemBuilder: (context, index) {
                  if (messages.isEmpty) {
                    return Center(child: Text("No messages yet."));
                  }
                  return messages[index];
                }
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
  bool isPlayingAudio = false;

  void initState() {
    super.initState();
    apiTTS.GptTTS.setAudioCompleteCallback(() {
      setState(() {
        isPlayingAudio = false; // 更新狀態為停止
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
              icon: Icon(
                // apiTTS.GptTTS.isPlayingAudio() ? Icons.stop : Icons.volume_up_rounded, // 更新圖標根據播放狀態
                isPlayingAudio ? Icons.stop : Icons.volume_up_rounded,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () async {
                if (isPlayingAudio) {
                  // stop playing audio 
                  await apiTTS.GptTTS.stopAudio();
                  selectedText = "";
                  setState(() {
                    isPlayingAudio = false; 
                  });
                } else {
                  // play audio                 
                  if (selectedText.isNotEmpty) {
                    setState(() {
                      isPlayingAudio = true; 
                    }); 
                    await apiTTS.GptTTS.streamedAudio(selectedText);
                    print("start playing selected audio");
                  } else {
                    setState(() {
                      isPlayingAudio = true; 
                    }); 
                    await apiTTS.GptTTS.streamedAudio(widget.message);
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
    );
  }
}