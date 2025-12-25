import 'package:flutter/material.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key});

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  // Individual toggle states for each card (start as OFF)
  bool _quadrantidsToggle = false;
  bool _eclipseToggle = false;
  bool _lyridsToggle = false;
  bool _etaToggle = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393,
      height: 852,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 26, 114, 1),
      ),
      child: Stack(
        children: <Widget>[
          // Header bar
          Positioned(
            top: 39,
            left: 19,
            child: Container(
              width: 346,
              height: 48,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 13,
                    left: 138,
                    child: const Text(
                      'EVENTS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Inter',
                        fontSize: 20,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
                  ),
                  // Notification bell icon button
                  Positioned(
                    top: 0,
                    left: 299,
                    child: Container(
                      width: 47,
                      height: 47,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(51, 57, 118, 1),
                        borderRadius: BorderRadius.all(Radius.elliptical(47, 47)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content with tabs and cards
          Positioned(
            top: 124,
            left: 26,
            child: Container(
              width: 340,
              height: 620,
              child: Stack(
                children: <Widget>[
                  // Tabs row (unchanged)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 339,
                      height: 40,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 148,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 205,
                            child: Container(
                              width: 134,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 11,
                            left: 16,
                            child: const Text(
                              'Meteor showers',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 11,
                            left: 242,
                            child: const Text(
                              'Eclipses',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 1: Quadrantids
                  Positioned(
                    top: 88,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          // Working toggle switch
                          Positioned(
                            top: 38,
                            left: 273,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _quadrantidsToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _quadrantidsToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/quad.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 17,
                            left: 115,
                            child: const Text(
                              'Quadrantids\nMeteor Shower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 63,
                            left: 111,
                            child: const Text(
                              'January 3–4, 2026',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 2: Total Lunar Eclipse
                  Positioned(
                    top: 233,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 271,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _eclipseToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _eclipseToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/total_lunar.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 26,
                            left: 111,
                            child: const Text(
                              'Total Lunar Eclipse',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 54,
                            left: 115,
                            child: const Text(
                              'March 3, 2026',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 3: Lyrids
                  Positioned(
                    top: 378,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 272,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _lyridsToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _lyridsToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/lyrids.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 118,
                            child: const Text(
                              'Lyrids Meteor\nShower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 62,
                            left: 118,
                            child: const Text(
                              'April 22–23, 2026.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 4: Eta Aquariids
                  Positioned(
                    top: 523,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 273,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _etaToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _etaToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/eta.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 13,
                            left: 118,
                            child: const Text(
                              'Eta Aquariids\nMeteor Shower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 119,
                            child: const Text(
                              'May 5–6, 2026.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}