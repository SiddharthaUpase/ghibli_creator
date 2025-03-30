import 'dart:async';
import 'package:flutter/material.dart';
import 'rick_roll_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progressValue = 0.0;
  final List<String> _loadingMessages = [
    'Analyzing image structure...',
    'Applying Ghibli color palette...',
    'Adding magical elements...',
    'Creating hand-drawn look...',
    'Finalizing Studio Ghibli style...',
    'Almost ready...',
  ];
  int _currentMessageIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.05;
          if (_progressValue > 0.2 &&
              _currentMessageIndex < _loadingMessages.length - 1) {
            _currentMessageIndex = (_progressValue * 6).floor();
            _currentMessageIndex = _currentMessageIndex.clamp(
              0,
              _loadingMessages.length - 1,
            );
          }
        } else {
          _timer.cancel();
          // Navigate to rick roll after 'conversion'
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RickRollScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Creating Your Ghibli Art',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/g1.jpeg', height: 150, width: 150),
              const SizedBox(height: 40),
              Text(
                _loadingMessages[_currentMessageIndex],
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.lightBlueAccent,
                ),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 20),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
