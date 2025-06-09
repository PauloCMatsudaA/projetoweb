import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../screens/listachat_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/chat_screen.dart';
import '../utils/animated_navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigo pra toda hora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
            onPressed: () {
              AnimatedNavigator.slideTo(context, const EditProfileScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            tooltip: 'Conversas',
            onPressed: () {
              AnimatedNavigator.slideTo(context, const ChatListScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por habilidade ou cidade',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _filter = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final users = docs
                    .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .where((user) => user.uid != currentUser?.uid)
                    .where((user) {
                      final combined = (user.city + user.skillsOffered.join(',') + user.skillsWanted.join(',')).toLowerCase();
                      return combined.contains(_filter);
                    })
                    .toList();

                if (users.isEmpty) {
                  return const Center(child: Text('Nenhum usuário encontrado.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cidade: ${user.city}'),
                            Text('Oferece: ${user.skillsOffered.join(", ")}'),
                            Text('Procura: ${user.skillsWanted.join(", ")}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            AnimatedNavigator.slideTo(
                              context,
                              ChatScreen(
                                peerId: user.uid,
                                peerName: user.name,
                              ),
                            );
                          },
                          child: const Text('Entrar em contato'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
