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
      home: const CoinCollectorGame(),
    );
  }
}

class CoinCollectorGame extends StatefulWidget {
  const CoinCollectorGame({super.key});

  @override
  _CoinCollectorGameState createState() => _CoinCollectorGameState();
}

class _CoinCollectorGameState extends State<CoinCollectorGame> {
  static const double _playerSize = 50;
  static const double _coinSize = 30;
  static const double _playerMoveStep = 0.08;
  static const double _coinSpawnInterval = 1.0;
  static const Duration _gameTick = Duration(milliseconds: 16);

  double _playerX = 0.5;
  int _score = 0;
  bool _isGameOver = false;
  Timer? _gameLoop;
  Timer? _coinSpawnTimer;
  List<Coin> coins = [];
  bool _isProcessingInput = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isGameOver = false;
      _playerX = 0.5;
      coins.clear();
    });

    _gameLoop?.cancel();
    _coinSpawnTimer?.cancel();

    _gameLoop = Timer.periodic(_gameTick, (timer) {
      if (_isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        _updateCoins();
        _checkCollisions();
      });
    });

    _coinSpawnTimer = Timer.periodic(Duration(seconds: _coinSpawnInterval.toInt()), (timer) {
      if (_isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        _spawnCoin();
      });
    });
  }

  void _updateCoins() {
    for (var coin in coins) {
      coin.y += 0.01;
    }
    coins.removeWhere((coin) => coin.y >= 1.0);
  }

  void _spawnCoin() {
    coins.add(Coin(
      x: Random().nextDouble(),
      y: 0.0,
    ));
  }

  void _checkCollisions() {
    final playerRect = Rect.fromCenter(
      center: Offset(
        MediaQuery.of(context).size.width * _playerX,
        MediaQuery.of(context).size.height - 100 - _playerSize / 2,
      ),
      width: _playerSize,
      height: _playerSize,
    );

    for (var coin in coins) {
      final coinRect = Rect.fromCenter(
        center: Offset(
          MediaQuery.of(context).size.width * coin.x,
          MediaQuery.of(context).size.height * coin.y,
        ),
        width: _coinSize,
        height: _coinSize,
      );

      if (playerRect.overlaps(coinRect)) {
        setState(() {
          coins.remove(coin);
          _score += 10;
        });
      }
    }
  }

  void _movePlayer(double direction) {
    setState(() {
      _playerX = (_playerX + direction).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (!_isProcessingInput) {
              _processTap(details as DragDownDetails);
            }
          },
          onTapUp: (_) {
            _resetMovement();
          },
          onTapCancel: () {
            _resetMovement();
          },
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: Text(
                  "Puntuación: $_score",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: screenWidth * _playerX - _playerSize / 2,
                child: Image.asset(
                  'assets/imagen.png',
                  width: _playerSize,
                  height: _playerSize,
                  fit: BoxFit.cover,
                ),
              ),
              for (var coin in coins)
                Positioned(
                  top: screenHeight * coin.y,
                  left: screenWidth * coin.x - _coinSize / 2,
                  child: Image.asset(
                    'assets/coin.png',
                    width: _coinSize,
                    height: _coinSize,
                    fit: BoxFit.cover,
                  ),
                ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      Icons.arrow_left,
                      () => _movePlayer(-_playerMoveStep),
                    ),
                    const SizedBox(width: 40),
                    _buildControlButton(
                      Icons.arrow_right,
                      () => _movePlayer(_playerMoveStep),
                    ),
                  ],
                ),
              ),
              if (_isGameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "GAME OVER",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTapDown: (_) {
        if (!_isProcessingInput) {
          _isProcessingInput = true;
          onPressed();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }

  void _processTap(DragDownDetails details) {
    if (_isProcessingInput) return;

    _isProcessingInput = true;
    final touchX = details.globalPosition.dx;
    final screenCenter = MediaQuery.of(context).size.width / 2;

    if (touchX < screenCenter) {
      _movePlayer(-_playerMoveStep);
    } else {
      _movePlayer(_playerMoveStep);
    }
  }

  void _resetMovement() {
    _isProcessingInput = false;
  }
}

class Coin {
  double x;
  double y;

  Coin({required this.x, required this.y});
}