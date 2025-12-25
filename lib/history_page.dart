import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A72),
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
        actions: [
          TextButton(
            onPressed: () {
              // Clear history logic later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared!')),
              );
            },
            child: const Text(
              'Clear all',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent history:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Placeholder items — replace with real data later
            _buildHistoryItem('Orion Nebula', 'Dec 23, 2025'),
            _buildHistoryItem('Andromeda Galaxy', 'Dec 22, 2025'),
            _buildHistoryItem('Jupiter', 'Dec 21, 2025'),
            _buildHistoryItem('Saturn', 'Dec 20, 2025'),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date) {
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