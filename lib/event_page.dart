import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key});

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  String selectedFilter = 'all';  // 'all', 'meteor', or 'eclipse'
  // Track which toggles are on (one for each event)
  late List<bool> reminderOn = List<bool>.filled(events.length, false);

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

  final List<Map<String, String>> events = [
    {
      'title': 'Quadrantids Meteor Shower',
      'date': 'January 3–4, 2026',
      'short': 'Up to 100 meteors/hour.',
      'full':
      'One of the strongest showers of the year! Fast, bright shooting stars that can reach up to 100 per hour under perfect conditions. Best viewed in the Northern Hemisphere after midnight. In 2026, a nearly full Moon will hide many fainter meteors, but the brightest ones will still shine through.',
      'image': 'assets/images/quad.jpg',
      'type': 'meteor',
    },
    {
      'title': 'Total Lunar Eclipse',
      'date': 'March 3, 2026',
      'short': 'Blood Moon! • Visible worldwide at night',
      'full':
      'A stunning "Blood Moon"! The Moon passes through Earth\'s shadow and turns a deep reddish color. Completely safe to watch with the naked eye. Visible anywhere it\'s nighttime — in 2026, best seen from the Americas, Europe, Africa, and parts of Asia. It lasts several hours, so plenty of time to enjoy.',
      'image': 'assets/images/total_lunar.jpg',
      'type': 'eclipse',
    },
    {
      'title': 'Lyrids Meteor Shower',
      'date': 'April 22–23, 2026',
      'short': '10–20 meteors/hour • Some bright fireballs',
      'full':
      'One of the oldest known showers, recorded for over 2,700 years! Produces about 10–20 meteors per hour, with some bright fireballs and fast streaks. Great dark skies in 2026 thanks to low moonlight. Best in the Northern Hemisphere — look toward the constellation Lyra after midnight.',
      'image': 'assets/images/lyrids.jpg',
      'type': 'meteor',
    },
    {
      'title': 'Eta Aquariids Meteor Shower',
      'date': 'May 5–6, 2026',
      'short': 'Up to 50 meteors/hour.',
      'full':
      'Fast and bright meteors from debris of famous Halley\'s Comet! Up to 50 per hour in perfect conditions, best viewed before dawn. Much stronger in the Southern Hemisphere, but visible worldwide. In 2026, bright moonlight may reduce numbers, but early risers can still catch great streaks.',
      'image': 'assets/images/eta.jpg',
      'type': 'meteor',
    },
    {
      'title': 'Perseids Meteor Shower',
      'date': 'August 12–13, 2026',
      'short': 'Up to 100 meteors/hour • Excellent dark skies!',
      'full':
      'One of the most popular and reliable showers! Up to 100 fast, bright meteors per hour with long trails. In 2026, perfect dark skies near New Moon make it extra spectacular. Best in the Northern Hemisphere during warm summer nights — a favorite for stargazing parties.',
      'image': 'assets/images/perseids.jpg',
      'type': 'meteor',
    },
    {
      'title': 'Total Solar Eclipse',
      'date': 'August 12, 2026',
      'short': 'Day turns to night! • Path over Europe',
      'full':
      'Day turns to sudden darkness! The Moon completely covers the Sun for up to 2 minutes, revealing the glowing corona. Total path crosses Greenland, Iceland, and northern Spain. Partial views across much of Europe and nearby areas. Never look directly without proper eclipse glasses (except during totality).',
      'image': 'assets/images/solar_eclipse.jpg',
      'type': 'eclipse',
    },
    {
      'title': 'Orionids Meteor Shower',
      'date': 'October 21–22, 2026',
      'short': '20–25 meteors/hour • From Halley\'s Comet',
      'full':
      'Fast meteors with glowing trails, also from Halley\'s Comet debris! About 20–25 per hour, some bright ones. Visible worldwide, best after midnight. In 2026, some moonlight interference, but still a beautiful show radiating from near Orion.',
      'image': 'assets/images/orionids.jpg',
      'type': 'meteor',
    },
    {
      'title': 'Geminids Meteor Shower',
      'date': 'December 13–14, 2026',
      'short': 'Up to 120 colorful meteors/hour!',
      'full':
      'Often the strongest and most colorful shower of the year! Up to 120 bright, multicolored meteors per hour, visible all night long. Great dark skies in 2026. Best worldwide, even before midnight — perfect for cold winter evenings under the stars.',
      'image': 'assets/images/geminids.jpg',
      'type': 'meteor',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the events based on selected tab
    final List<Map<String, String>> filteredEvents = events.where((event) {
      if (selectedFilter == 'all') return true;
      return event['type'] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(gradient: _cosmicGradient),
        child: Column(
          children: [
            // Add the "EVENTS" title manually at the top
            Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 20),  // Space from very top
              child: const Text(
                'EVENTS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Tabs row — tappable filters
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = (selectedFilter == 'meteor') ? 'all' : 'meteor';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selectedFilter == 'meteor' 
                            ? const LinearGradient(colors: [Color(0xFF5F6ADC), Color(0xFF725ABA)])
                            : const LinearGradient(colors: [Color(0xFF1E244B), Color(0xFF2D325A)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: selectedFilter == 'meteor' 
                            ? [BoxShadow(color: const Color(0xFF5F6ADC).withOpacity(0.4), blurRadius: 10)] : null,
                      ),
                      child: const Text('Meteor showers', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = (selectedFilter == 'eclipse') ? 'all' : 'eclipse';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: selectedFilter == 'eclipse' 
                            ? const LinearGradient(colors: [Color(0xFF5F6ADC), Color(0xFF725ABA)])
                            : const LinearGradient(colors: [Color(0xFF1E244B), Color(0xFF2D325A)]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: selectedFilter == 'eclipse' 
                            ? [BoxShadow(color: const Color(0xFF5F6ADC).withOpacity(0.4), blurRadius: 10)] : null,
                      ),
                      child: const Text('Eclipses', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable list of filtered events
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(26, 0, 26, 40),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color.fromRGBO(51, 57, 118, 1),
                            title: Text(
                              event['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              event['full']!,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 150),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1A1F2E), Color(0xFF2D325A)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF5F6ADC).withOpacity(0.15), blurRadius: 8, spreadRadius: 1)
                          ]
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(event['image']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event['title']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event['date']!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event['short']!,
                                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //toggles!!!!
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Switch(
                                value: reminderOn[index],  // This will be true or false for each card
                                onChanged: (bool value) {
                                  setState(() {
                                    reminderOn[index] = value;  // This flips the switch on/off
                                  });
                                },
                                activeColor: const Color(0xFF725ABA),  // Purple when on
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.grey.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (index * 100).ms).fade(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
