import 'dart:async';
import 'dart:math';

import 'package:counter_app/particle.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    // AnimationController for initial Burst Animation of Text
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _animation = Tween(begin: 1.0, end: 2.0).animate(_animationController);
    timer = Timer.periodic(
        Duration(milliseconds: (fps * 1000).floor()), frameBuilder);
    super.initState();
  }

  _animationListener() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  frameBuilder(dynamic timer) {
    for (var pt in particles) {
      double dragForceX =
          0.5 * airDensity * pow(pt.velocity.x, 2) * dragCof * pt.area;
      double dragForceY =
          0.5 * airDensity * pow(pt.velocity.y, 2) * dragCof * pt.area;

      dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
      dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;

      double accX = dragForceX / pt.mass;
      double accY = dragForceY / pt.mass + gravity; //f = m x a

      pt.velocity.x += accX * fps;
      pt.velocity.y += accY * fps;

      pt.position.x += pt.velocity.x * fps * 100;
      pt.position.y += pt.velocity.y * fps * 100;

      boxCollision(pt);
    }
    setState(() {});
  }

  late AnimationController _animationController;
  late Animation _animation;
  final List<Color> colors = [
    const Color(0xFFFFC100),
    const Color(0xFFFF9A00),
    const Color(0xFFFF4D00),
    const Color(0xFFFF0000)
  ];
  final GlobalKey _boxKey = GlobalKey();
  final Random random = Random();
  dynamic counterText = {"count": 1, "color": const Color(0xFFFFC100)};
  Rect boxSize = Rect.zero;
  List<Particle> particles = [];
  final double fps = 1 / 64;
  late Timer timer;
  final double gravity = 9.81, dragCof = 0.47, airDensity = 1.1644;

  boxCollision(Particle pt) {
    //right wall
    if (pt.position.x > boxSize.width - pt.radius) {
      pt.position.x = boxSize.width - pt.radius;
      pt.velocity.x *= pt.jumpVector;
    }
    //left wall
    if (pt.position.x < pt.radius) {
      pt.position.x = pt.radius;
      pt.velocity.x *= pt.jumpVector;
    }
    //floor
    if (pt.position.y > boxSize.height - pt.radius) {
      pt.position.y = boxSize.height - pt.radius;
      pt.velocity.y *= pt.jumpVector;
    }
  }

  burstParticle() {
    if (particles.length > 200) {
      particles.removeRange(0, 75);
    }

    _animationController.forward();
    _animationController.addListener(_animationListener);

    double colorRandom = random.nextDouble();

    Color color = colors[(colorRandom * colors.length).floor()];
    String previousCount = "${counterText['count']}";
    Color prevColor = counterText['color'];
    counterText['count'] = counterText['count'] + 1;
    counterText['color'] = color;

    int count = random.nextInt(25).clamp(7, 25);
    for (var i = 0; i < count; i++) {
      Particle p = Particle();
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      double randomX = random.nextDouble() * 4.0;
      if (i % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = random.nextDouble() * -7.0;
      p.velocity = PVector(randomX, randomY);
      p.radius = (random.nextDouble() * 10.0).clamp(2.0, 10.0);
      p.color = prevColor;
      particles.add(p);
    }

    List<String> numbers = previousCount.split("");
    for (int x = 0; x < numbers.length; x++) {
      double randomX = random.nextDouble();
      if (x % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = random.nextDouble() * -7.0;
      Particle p = Particle();
      p.type = ParticleType.TEXT;
      p.text = numbers[x];
      p.radius = 25;
      p.color = color;
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX * 4.0, randomY);
      particles.add(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    boxSize = Rect.fromLTRB(0, 0, size.width, size.height - 80);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: counterText['color'],
        title: const Text('Burst Counter'),
      ),
      body: Container(
        key: _boxKey,
        child: Stack(
          children: [
            Center(
              child: Text(
                "${counterText['count']}",
                textScaleFactor: _animation.value,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: counterText["color"],
                ),
              ),
            ),
            ...particles.map((pt) {
              if (pt.type == ParticleType.TEXT) {
                return Positioned(
                    top: pt.position.y,
                    left: pt.position.x,
                    child: Container(
                      child: Text(
                        "${pt.text}",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: pt.color),
                      ),
                    ));
              } else {
                return Positioned(
                    top: pt.position.y,
                    left: pt.position.x,
                    child: Container(
                      width: pt.radius * 2,
                      height: pt.radius * 2,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: pt.color),
                    ));
              }
            }).toList()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: burstParticle,
        backgroundColor: counterText['color'],
        child: const Icon(Icons.add),
      ),
    );
  }
}
