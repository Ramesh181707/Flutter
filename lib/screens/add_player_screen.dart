import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AddPlayerScreen extends StatefulWidget {
  final ParseObject? player;

  const AddPlayerScreen({super.key, this.player});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController teamController;
  late TextEditingController roleController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.player?.get<String>('name') ?? '');
    teamController =
        TextEditingController(text: widget.player?.get<String>('team') ?? '');
    roleController =
        TextEditingController(text: widget.player?.get<String>('role') ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    teamController.dispose();
    roleController.dispose();
    super.dispose();
  }

  Future<void> savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    ParseObject player = widget.player ?? ParseObject('Player');
    player
      ..set('name', nameController.text.trim())
      ..set('team', teamController.text.trim())
      ..set('role', roleController.text.trim());

    final response = await player.save();

    setState(() => isSaving = false);

    if (response.success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${response.error!.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player == null ? 'Add Player' : 'Edit Player'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '←', // Unicode left arrow as back button
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: teamController,
                decoration: const InputDecoration(labelText: 'Team'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a team' : null,
              ),
              TextFormField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a role' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : savePlayer,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : Text(widget.player == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
