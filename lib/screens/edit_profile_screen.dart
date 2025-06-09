import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/user_provider.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _skillsOfferedController = TextEditingController();
  final _skillsWantedController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _cityController.text = user.city;
      _skillsOfferedController.text = user.skillsOffered.join(', ');
      _skillsWantedController.text = user.skillsWanted.join(', ');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    setState(() => _saving = true);

    final updatedUser = UserModel(
      uid: user.uid,
      name: _nameController.text.trim(),
      email: user.email,
      city: _cityController.text.trim(),
      skillsOffered: _skillsOfferedController.text.trim().split(','),
      skillsWanted: _skillsWantedController.text.trim().split(','),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(updatedUser.toMap());

    userProvider.registerUser(updatedUser);

    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
    Navigator.pop(context);
  }

  InputDecoration styledInput(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Atualize seus dados',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: styledInput('Nome completo'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Digite o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: styledInput('Cidade'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Digite a cidade' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _skillsOfferedController,
                        decoration:
                            styledInput('Habilidades oferecidas (separadas por vírgula)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _skillsWantedController,
                        decoration:
                            styledInput('Habilidades procuradas (separadas por vírgula)'),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar alterações'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
