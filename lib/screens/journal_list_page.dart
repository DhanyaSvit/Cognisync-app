import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_page.dart';

class JournalListPage extends StatelessWidget {
  final VoidCallback? onComplete;
  const JournalListPage({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Not signed in', style: TextStyle(color: Colors.white))),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('My Journal', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journals')
            .where('uid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No journal entries yet.', style: TextStyle(color: Colors.white70)),
            );
          }
          final entries = snapshot.data!.docs;
          // Sort by createdAt descending if present, else fallback to unsorted
          entries.sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['createdAt'];
            final bTime = (b.data() as Map<String, dynamic>)['createdAt'];
            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            } else if (aTime is Timestamp) {
              return -1;
            } else if (bTime is Timestamp) {
              return 1;
            } else {
              return 0;
            }
          });
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final data = entries[i].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final content = data['content'] ?? '';
              final ts = data['createdAt'] as Timestamp?;
              final date = ts?.toDate();
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    content.length > 60 ? content.substring(0, 60) + '...' : content,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: date != null
                      ? Text(
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        )
                      : null,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        String dateTimeStr = '';
                        if (date != null) {
                          final h = date.hour.toString().padLeft(2, '0');
                          final m = date.minute.toString().padLeft(2, '0');
                          dateTimeStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $h:$m';
                        }
                        return AlertDialog(
                          backgroundColor: Colors.black,
                          title: Text(title, style: const TextStyle(color: Colors.white)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dateTimeStr.isNotEmpty)
                                Text(dateTimeStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(content, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JournalPage(
                onComplete: onComplete,
              ),
            ),
          );
          if (result == true && onComplete != null) {
            onComplete!();
          }
        },
        tooltip: 'Add New Journal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
