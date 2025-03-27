import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AvoidObstaclesGame(),
    );
  }
}

class AvoidObstaclesGame extends StatefulWidget {
  const AvoidObstaclesGame({super.key});

  @override
  _AvoidObstaclesGameState createState() => _AvoidObstaclesGameState();
}

class _AvoidObstaclesGameState extends State<AvoidObstaclesGame> {
  static const double _playerSize = 50;
  static const double _obstacleSize = 50;
  static const double _playerMoveStep = 0.1;
  static const double _obstacleSpeed = 0.02;
  static const Duration _gameTick = Duration(milliseconds: 50);

  double _playerX = 0.5;
  double _obstacleX = 0.5;
  double _obstacleY = 0.0;
  int _score = 0;
  bool _isGameOver = false;
  Timer? _gameLoop;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isGameOver = false;
      _obstacleY = 0.0;
      _randomizeObstaclePosition();
    });

    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(_gameTick, (timer) {
      if (_isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        _obstacleY += _obstacleSpeed;
        if (_obstacleY >= 1.0) {
          _obstacleY = 0.0;
          _randomizeObstaclePosition();
          _score++;
        }
        _checkCollision();
      });
    });
  }

  void _movePlayer(double direction) {
    setState(() {
      _playerX = (_playerX + direction).clamp(0.0, 1.0);
    });
  }

  void _checkCollision() {
    if ((_playerX - _obstacleX).abs() < 0.08 && _obstacleY > 0.85) {
      _gameOver();
    }
  }

  void _gameOver() {
    _isGameOver = true;
    _gameLoop?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Game Over!"),
        content: Text("Puntuación final: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  void _randomizeObstaclePosition() {
    _obstacleX = Random().nextDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              "Puntuación: $_score",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 100,
            left: screenWidth * _playerX - _playerSize / 2,
            child: Container(
              width: _playerSize,
              height: _playerSize,
              color: Colors.blue,
            ),
          ),
          Positioned(
            top: screenHeight * _obstacleY,
            left: screenWidth * _obstacleX - _obstacleSize / 2,
            child: Container(
              width: _obstacleSize,
              height: _obstacleSize,
              color: Colors.red,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _movePlayer(-_playerMoveStep),
                  child: const Icon(Icons.arrow_left),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _movePlayer(_playerMoveStep),
                  child: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
