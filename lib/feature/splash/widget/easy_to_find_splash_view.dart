import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated splash visual for "Easy to find".
///
/// Purely presentational: it plays its intro animation and reports back through
/// [onAnimationDone]. Routing stays in SplashScreen so config loading, forced
/// update and maintenance checks keep owning navigation.
class EasyToFindSplashView extends StatefulWidget {
  const EasyToFindSplashView({
    super.key,
    required this.onAnimationDone,
    this.showLoadingBar = true,
  });

  final VoidCallback onAnimationDone;
  final bool showLoadingBar;

  @override
  State<EasyToFindSplashView> createState() => _EasyToFindSplashViewState();
}

class _EasyToFindSplashViewState extends State<EasyToFindSplashView>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF06172F);
  static const Color deepNavy = Color(0xFF020A16);
  static const Color gold = Color(0xFFFFC342);

  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.06, 0.42, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.58, curve: Curves.easeOutBack),
      ),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.62, curve: Curves.easeOut),
    );

    _controller
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onAnimationDone();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF0B2348), navy, deepNavy],
                stops: <double>[0, 0.48, 1],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.16),
                radius: 0.62,
                colors: <Color>[
                  Color(0x2BFFC342),
                  Color(0x0DFFC342),
                  Color(0x00FFC342),
                ],
                stops: <double>[0, 0.48, 1],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: _DiscoveryFieldPainter(
                  progress: Curves.easeOutCubic.transform(
                    math.min(_controller.value / 0.78, 1.0),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 25),
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Semantics(
                        label: 'Easy to find',
                        child: const SizedBox(
                          width: 154,
                          height: 154,
                          child: CustomPaint(painter: _SearchLensPainter()),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screen.height < 700 ? 26 : 34),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _titleOffset,
                      child: const _BrandTitle(),
                    ),
                  ),
                  const SizedBox(height: 13),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: Text.rich(
                      const TextSpan(
                        children: <InlineSpan>[
                          TextSpan(text: 'Find'),
                          TextSpan(text: '  •  ', style: TextStyle(color: gold)),
                          TextSpan(text: 'Discover'),
                          TextSpan(text: '  •  ', style: TextStyle(color: gold)),
                          TextSpan(text: 'Enjoy'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  const Spacer(flex: 22),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: const Text(
                      'YOUR WORLD, EASIER TO FIND',
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 21),
                  if (widget.showLoadingBar) _LoadingBar(controller: _controller),
                  SizedBox(height: screen.height < 700 ? 24 : 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Easy to find',
      child: ExcludeSemantics(
        child: Text.rich(
          const TextSpan(
            children: <InlineSpan>[
              TextSpan(text: 'Easy to '),
              TextSpan(text: 'find', style: TextStyle(color: Color(0xFFFFC342))),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.25,
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 4,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2B42),
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: Curves.easeInOutCubic.transform(controller.value),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFFF3A918), Color(0xFFFFD878)],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DiscoveryFieldPainter extends CustomPainter {
  const _DiscoveryFieldPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.39);
    final double shortest = math.min(size.width, size.height);

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4);

    for (int i = 0; i < 4; i++) {
      final double radius = shortest * (0.19 + (i * 0.105)) * progress;
      glow
        ..strokeWidth = i == 0 ? 1.35 : 0.75
        ..color = const Color(0xFFFFC342)
            .withValues(alpha: (0.25 - (i * 0.045)) * progress);
      canvas.drawCircle(center, radius, glow);
    }

    final Paint dotPaint = Paint();
    const List<double> angles = <double>[-2.62, -1.12, -0.18, 0.63, 2.34];
    for (int i = 0; i < angles.length; i++) {
      final double radius = shortest * (0.29 + ((i % 2) * 0.11));
      final Offset point = center +
          Offset(math.cos(angles[i]), math.sin(angles[i])) * radius * progress;
      dotPaint.color =
          const Color(0xFFFFD878).withValues(alpha: 0.6 * progress);
      canvas.drawCircle(point, i == 2 ? 2.6 : 1.8, dotPaint);
    }

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.025 * progress)
      ..strokeWidth = 0.5;
    const double gap = 28;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiscoveryFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SearchLensPainter extends CustomPainter {
  const _SearchLensPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.43, size.height * 0.40);
    final double radius = size.width * 0.275;
    final Offset handleStart = center + Offset(radius * 0.70, radius * 0.70);
    final Offset handleEnd = Offset(size.width * 0.88, size.height * 0.88);

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x77FFC342)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, radius, glow);
    canvas.drawLine(handleStart, handleEnd, glow);

    final Paint shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x99000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    const Offset shadowOffset = Offset(0, 6);
    canvas.drawCircle(center + shadowOffset, radius, shadow);
    canvas.drawLine(handleStart + shadowOffset, handleEnd + shadowOffset, shadow);

    final Rect shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Paint goldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.135
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFFE7A6),
          Color(0xFFFFC342),
          Color(0xFFF2A20E),
        ],
      ).createShader(shaderRect);
    canvas.drawCircle(center, radius, goldPaint);
    canvas.drawLine(handleStart, handleEnd, goldPaint);

    final Paint highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xCCFFF2C9);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.12,
      math.pi * 0.58,
      false,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
