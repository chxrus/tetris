import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class BoardEffects extends PositionComponent {
  BoardEffects() {
    anchor = Anchor.topLeft;
    priority = 100;
  }

  static const double _flashIn = 0.12;
  static const double _flashHold = 0.14;
  static const double _flashOut = 0.26;
  static const double _rowStagger = 0.04;
  static const double _flashAlpha = 0.90;

  void flashRows({
    required List<int> rows,
    required double cell,
    required double width,
  }) {
    final sorted = List<int>.from(rows)..sort();

    for (var i = 0; i < sorted.length; i++) {
      final y = sorted[i];
      final startDelay = i * _rowStagger;

      final stripe = RectangleComponent(
        position: Vector2(0, y * cell),
        size: Vector2(width, cell),
        anchor: Anchor.topLeft,
        paint: Paint()..color = Colors.black,
        priority: 101,
      )..opacity = 0;

      stripe.add(
        SequenceEffect([
          OpacityEffect.to(
            _flashAlpha,
            EffectController(
              duration: _flashIn,
              startDelay: startDelay,
              curve: Curves.easeOutCubic,
            ),
          ),
          OpacityEffect.to(_flashAlpha, EffectController(duration: _flashHold)),
          OpacityEffect.to(
            0.0,
            EffectController(duration: _flashOut, curve: Curves.easeInCubic),
          ),
          RemoveEffect(),
        ]),
      );

      add(stripe);
    }
  }

  void spawnLandingParticles({
    required Iterable<Vector2> worldCenters,
    required int colorValue,
  }) {
    final paint = Paint()..color = Color(colorValue).withValues(alpha: 0.95);
    for (final p in worldCenters) {
      add(
        ParticleSystemComponent(
          priority: 99,
          particle: TranslatedParticle(
            offset: p,
            child: Particle.generate(
              lifespan: 0.45,
              count: 12,
              generator: (i) {
                final ang = (-math.pi / 2) + (i / 12) * math.pi;
                final speed = 70 + math.Random().nextDouble() * 90;
                return AcceleratedParticle(
                  acceleration: Vector2(0, 420),
                  speed: Vector2(math.cos(ang) * speed, math.sin(ang) * speed),
                  child: CircleParticle(
                    radius: 1.6 + math.Random().nextDouble() * 2.0,
                    paint: paint,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }
}
