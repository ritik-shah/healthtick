import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindful Meal Timer',
      color: Colors.grey,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        hintColor: Colors.lightGreen,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
        ),
      ),
      home: const MindfulMealTimer(),
    );
  }
}

class MindfulMealTimer extends StatefulWidget {
  const MindfulMealTimer({super.key});

  @override
  _MindfulMealTimerState createState() => _MindfulMealTimerState();
}

class _MindfulMealTimerState extends State<MindfulMealTimer> {
  List<String> pageMessagestoptop = [
    'Nom nom :)',
    'Break Time',
    'Finish your meal',
  ];
  List<String> pageMessages = [
    'Focus on Eating Slowly',
    'level of fullness',
    '',
  ];
  List<String> pageMessagestop = [
    'You have 10 minutes to eat before the pause.',
    'Take a five-minute break to check in on your',
    'You can eat until you feel full.',
  ];
  final PageController _pageController = PageController();
  Timer? _timer;
  int _remainingTime = 1 * 60; // 1 minute in seconds
  bool _isTimerRunning = false;
  int _totalLines = 60;
  int _interval = 1;
  bool _isSoundOn = true; // Toggle this for sound on/off
  final player = AudioPlayer();
  late List<Color> lineColors;
  _MindfulMealTimerState() {
    // Initialize lineColors starting from the top position (12'o clock)
    lineColors = List<Color>.generate(
      _totalLines,
          (index) {
        // Calculate the adjusted index based on the starting position
        int adjustedIndex = (index + _totalLines - (_totalLines ~/ 4)) % _totalLines;
        return adjustedIndex < (_totalLines ~/ 61) ? Colors.grey : Colors.green;
      },
    );
  }





  @override
  void initState() {
    super.initState();
    player.play(AssetSource('countdown_tick.mp3'));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 6 && _isSoundOn) {
        player.play(AssetSource('countdown_tick.mp3'));
        player.setReleaseMode(ReleaseMode.loop);
        if (_remainingTime == 1) {
          player.stop();
        }
      }
      _updateLineColor();
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _toggleTimer() {
    if (_remainingTime > 0) {
      setState(() {
        _isTimerRunning = !_isTimerRunning;

        if (_isTimerRunning) {
          _startTimer();
        } else {
          _pauseTimer();
        }
      });
    } else {
      // If the timer has ended, reset the flag without toggling
      setState(() {
        _isTimerRunning = false;
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 1 * 60;
      _isTimerRunning = false;
    });
  }

  void _updateLineColor() {
    int lineIndex = ((_totalLines * _remainingTime) / 60).round();

    if (lineIndex < _totalLines) {
      _interval = 60 ~/ _totalLines;
      _interval = _interval == 0 ? 1 : _interval;

      if (lineIndex % _interval == 0) {
        _totalLines = 60 ~/ _interval;
        _interval = 1;
      }
    }

    _updateLineColors(lineIndex);
  }
  void resetLineColors() {
    setState(() {
      // Re-initialize lineColors based on your desired logic
      lineColors = List<Color>.generate(
        _totalLines,
            (index) {
          // Calculate the adjusted index based on the starting position
          int adjustedIndex = (index + _totalLines - (_totalLines ~/ 4)) % _totalLines;
          return adjustedIndex < (_totalLines ~/ 61) ? Colors.grey : Colors.green;
        },
      );
    });
  }
  void _updateLineColors(int lineIndex) {
    setState(() {
      _remainingTime--;

      lineIndex = ((_totalLines * _remainingTime) / 60).round();

      lineColors = List<Color>.generate(
        _totalLines,
            (index) {
          return index < lineIndex ? Colors.green : Colors.grey;
        },
      );
    });

    if (_remainingTime == 0) {
      _timer?.cancel();
      player.stop();
      _moveToNextPage();
    }
  }



  void _moveToNextPage() {
    resetLineColors();
    int nextPage = _pageController.page?.toInt() ?? 0;
    nextPage++;
    if (nextPage < 3) {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // Reset the timer
      _timer?.cancel();
      setState(() {
        _remainingTime = 1 * 60;
        _isTimerRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindful Meal Timer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildTimerPage(0),
              _buildTimerPage(1),
              _buildTimerPage(2),
            ],
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPage(int pageIndex) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              pageMessagestoptop[pageIndex],
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Center(
            child: Text(
              pageMessagestop[pageIndex],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          Center(
            child: Text(
              pageMessages[pageIndex],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                width: 230,
                height: 230,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // White round container
                ),
              ),
              CustomPaint(
                painter: TimerPainter(_remainingTime, _totalLines,
                    interval: _interval, lineColors: lineColors),
                child: Container(
                  width: 200,
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'minutes remaining',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Colors.green,
                value: _isSoundOn,
                onChanged: (value) {
                  setState(() {
                    _isSoundOn = value;
                  });
                },
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sound On'),
            ],
          ),
          Stack(
            children: [
              Positioned(
                top: 18,
                left: 14,
                child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.78,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xff90b7a0),
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.all(10),
                child: Card(
                  color: const Color(0xffd0ecda),
                  elevation: 0,
                  child: InkWell(
                    onTap: _toggleTimer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Center(
                        child: Text(
                          _isTimerRunning ? 'PAUSE' : 'START',
                          style: const TextStyle(
                            color: Color(0xff0c1916),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.78,
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: InkWell(
                onTap: _stopTimer,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      'LET\'S STOP I\'M FULL NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: 3,
      effect: const SlideEffect(
        dotHeight: 12,
        dotWidth: 12,
        activeDotColor: Colors.white,
        dotColor: Colors.grey,
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final int seconds;
  int totalLines;
  int interval;
  List<Color> lineColors;

  TimerPainter(this.seconds, this.totalLines, {this.interval = 1, required this.lineColors});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..strokeCap = StrokeCap.round;

    double radius = size.width / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double angle = -2 * pi * (seconds / 60);

    for (int lineIndex = 0; lineIndex < totalLines; lineIndex++) {
      double i = -pi / 2 - 2 * pi * (lineIndex / totalLines);


      double x1, y1, x2, y2;

      if (lineIndex % 15 == 0) {
        paint.strokeWidth = 4;
        x1 = centerX + radius * cos(i);
        y1 = centerY + radius * sin(i);
        x2 = centerX + radius * 0.8 * cos(i);
        y2 = centerY + radius * 0.8 * sin(i);
      } else {
        paint.strokeWidth = 2;
        x1 = centerX + radius * 0.9 * cos(i);
        y1 = centerY + radius * 0.9 * sin(i);
        x2 = centerX + radius * cos(i);
        y2 = centerY + radius * sin(i);
      }

      paint.color = lineColors[lineIndex];
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.green; // Set color based on the last line
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -pi / 2,
      angle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
