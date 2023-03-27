
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:myapp/providers/chat_provider.dart';
import 'package:myapp/widgets/progress_indicator.dart';

import '../models/friend.dart';


class ChatPage extends StatefulWidget {
  final types.Room room;
  final Friend friend;

  const ChatPage({super.key, required this.room, required this.friend});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatProvider _provider;
  @override
  void initState() {
    _provider = ChatProvider(room: widget.room);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          context.pop();
        }, icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: widget.friend.photo,),
            const SizedBox(width: 8,),
            Column(
              children: [
                Align(alignment: Alignment.centerLeft,child: Text(widget.friend.name)),
                Align(alignment: Alignment.centerLeft,child: Text(widget.friend.username, style: const TextStyle(color: Colors.grey),))
              ],
            )
          ],
        ),
      ),
      body: StreamBuilder<types.Room>(
        initialData: widget.room,
        stream: FirebaseChatCore.instance.room(widget.room.id),
        builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
          initialData: const [],
          stream: FirebaseChatCore.instance.messages(snapshot.data!),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return const MyCircularProgress();
            }
            return Chat(
            isAttachmentUploading: _provider.isAttachmentUploading,
            messages: snapshot.data ?? [],
            onAttachmentPressed: () => _provider.handleAttachmentPressed(context),
            onMessageTap: _provider.handleMessageTap,
            onPreviewDataFetched: _provider.handlePreviewDataFetched,
            onSendPressed: _provider.handleSendPressed,
            user: types.User(
              id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
            ),
          );
          }
        ),
      )
  );


}