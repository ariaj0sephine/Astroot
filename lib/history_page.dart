import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Same beautiful cosmic gradient
  static const LinearGradient _cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF00132D),
      Color(0xFF00142E),
      Color(0xFF001E45),
      Color(0xFF002657),
    ],
    stops: [0.0, 0.15, 0.54, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _cosmicGradient),
        child: currentUser == null
            ? _buildSignInPrompt()
            : Padding(
          // ← THIS IS THE FIX: big top padding so nothing feels congested
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 110,    // ← increased for clean space below app bar
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent history:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5), // extra breathing space
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(currentUser.uid)
                      .collection('observations')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading history', style: TextStyle(color: Colors.red)),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No observations yet.\nGo snap some stars!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final observations = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: observations.length,
                      itemBuilder: (context, index) {
                        final doc = observations[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final String starName = data['star_name'] ?? 'Unknown Object';
                        final String fact = data['fact'] ?? '';
                        final dynamic ts = data['timestamp'];

                        // FIXED: show real timestamp (string or Timestamp)
                        String displayDate = 'Unknown Date';
                        if (ts != null) {
                          if (ts is Timestamp) {
                            displayDate = _formatDate(ts);
                          } else if (ts is String) {
                            displayDate = ts; // your current "25 February 2026 at 20:31:14 UTC+5:30"
                          } else {
                            displayDate = ts.toString();
                          }
                        }

                        return _buildHistoryItem(starName, fact, displayDate);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_border, color: Colors.white70, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Sign in to see your stargazing history!',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              print('Navigate to sign-in');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format Timestamp nicely (if you ever save real Timestamp)
  String _formatDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  Widget _buildHistoryItem(String starName, String fact, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  starName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (fact.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      fact,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}