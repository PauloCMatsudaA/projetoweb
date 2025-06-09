import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Conversas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allUsers = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();

          return ListView.builder(
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final userDoc = allUsers[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final peerId = userDoc.id;
              final peerName = userData['name'] ?? 'Sem nome';
              final chatId = getChatId(currentUser.uid, peerId);

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                    return const SizedBox(); // Não mostra se não houve conversa ainda
                  }

                  final lastMessage = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(peerName),
                    subtitle: Text(lastMessage['text'] ?? ''),
                    trailing: const Icon(Icons.chat_bubble_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(peerId: peerId, peerName: peerName),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
