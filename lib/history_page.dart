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

  // Cosmic gradient—exact match from HomeScreen for immersive feel
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
    // Get current user—if null, show sign-in prompt
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to let gradient shine
      extendBodyBehindAppBar: true,  // ← Add this exact line
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
        // No actions—clean top bar
      ),
      body: Container(  // Wrap body in gradient container
        decoration: const BoxDecoration(gradient: _cosmicGradient),
        child: currentUser == null
            ? _buildSignInPrompt()  // No user? Prompt to sign in
            : Padding(
          padding: const EdgeInsets.all(80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Recent history:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(  // Takes full space, scrolls if many items
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(currentUser.uid)  // User's private collection
                      .collection('observations')
                      .orderBy('date', descending: true)  // Newest first
                      .snapshots(),  // Real-time listener
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Oops! Error loading history. Try again.', style: TextStyle(color: Colors.white)));
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

                    // Build list from real data
                    final observations = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: observations.length,
                      itemBuilder: (context, index) {
                        final doc = observations[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final String objectName = data['objectName'] ?? 'Unknown Object';
                        final Timestamp? dateStamp = data['date'];
                        final String date = _formatDate(dateStamp);  // Helper below

                        return _buildHistoryItem(objectName, date);
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

  // Sign-in prompt (simple—ties to your profile/auth)
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
              // Push to your sign-in screen (add route later, or print for now)
              print('Navigate to sign-in');  // Replace with Navigator.push to auth page
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format Timestamp to "Dec 31, 2025" (matches screenshot and current date)
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown Date';
    final dateTime = timestamp.toDate();
    // Outputs "Dec 31, 2025" format—perfect for your test data
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dateTime.month - 1];
    return '${month} ${dateTime.day}, ${dateTime.year}';
  }

  // Your original item builder (unchanged—looks just like screenshot, blends with gradient)
  Widget _buildHistoryItem(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),  // Subtle transparency—glows against gradient
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
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
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