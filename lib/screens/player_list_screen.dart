import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'add_player_screen.dart';
import 'login_screen.dart';

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  List<ParseObject> players = [];

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    final query = QueryBuilder(ParseObject('Player'))..orderByDescending('createdAt');
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        players = response.results!.cast<ParseObject>();
      });
    }
  }

  Future<void> deletePlayer(int index) async {
    final player = players[index];

    setState(() {
      players.removeAt(index);
    });

    final response = await player.delete();

    if (!response.success) {
      setState(() {
        players.insert(index, player);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${response.error?.message ?? 'Unknown error'}')),
      );
    }
  }

  void openAddEditScreen({ParseObject? player}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPlayerScreen(player: player),
      ),
    );
    fetchPlayers();
  }

  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      await user.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '←',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: players.isEmpty
            ? const Center(child: Text('No players found.'))
            : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(player.get<String>('name') ?? ''),
                      subtitle: Text(
                        'Team: ${player.get<String>('team') ?? ''}, Role: ${player.get<String>('role') ?? ''}',
                      ),
                      trailing: GestureDetector(
                        onTap: () => deletePlayer(index),
                        child:
                        const Text('X',              style: TextStyle(fontSize: 24, color: Colors.red),
),
                        //  const Icon(Icons.delete, color: Colors.red),
                      ),
                      onTap: () => openAddEditScreen(player: player),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddEditScreen(),
        backgroundColor: Colors.blue,
        tooltip: 'Add Player',
        child: const Center(
            child: Text(
              '+', // Unicode left arrow as back button
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
