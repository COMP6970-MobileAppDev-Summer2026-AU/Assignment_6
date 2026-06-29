// =============================================================================
// screens/front_screen.dart
// App landing page — shown every launch before entering ScanLog
// Matches JAJI design language from Assignments 2–5
// =============================================================================

import 'package:flutter/material.dart';
import 'home_screen.dart';

class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _enter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer,
              scheme.primaryContainer.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),

                      // ── App icon ─────────────────────────────────────────
                      Container(
                        width:  110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.document_scanner_outlined,
                          size:  52,
                          color: scheme.primary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── App name ──────────────────────────────────────────
                      Text('ScanLog',
                          style: TextStyle(
                              fontSize:   34,
                              fontWeight: FontWeight.bold,
                              color:      scheme.primary,
                              letterSpacing: 0.5)),
                      Text('On-Device ML Text Recognition',
                          style: TextStyle(
                              fontSize:   13,
                              color: scheme.primary.withValues(alpha: 0.7),
                              letterSpacing: 1.0)),

                      const SizedBox(height: 28),

                      // ── Developer card ────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_outline,
                                color: scheme.primary, size: 26),
                            const SizedBox(height: 6),
                            const Text('Developed by',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text('Jahidul Arafat',
                                style: TextStyle(
                                    fontSize:   20,
                                    fontWeight: FontWeight.bold,
                                    color:      scheme.primary)),
                            const SizedBox(height: 8),
                            _infoRow(context, Icons.school_outlined,
                                'PhD Student, Dept. of Computer Science & Software Engineering'),
                            _infoRow(context, Icons.star_outline,
                                'Presidential & Woltosz Graduate Research Fellow'),
                            _infoRow(context, Icons.work_outline,
                                'Former L3 Senior Solution Architect (MLOps), Oracle (Singapore)'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── App info card ─────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text('About This App',
                                style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   15,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _appInfoRow('App',        'ScanLog'),
                            _appInfoRow('Course',     'COMP 6910 — Mobile App Development'),
                            _appInfoRow('Module',     'M6 — On-Device Machine Learning'),
                            _appInfoRow('Assignment', 'Assignment 6'),
                            _appInfoRow('ML Engine',  'Apple Vision · Google ML Kit'),
                            _appInfoRow('Track',      'Flutter / Dart'),
                            _appInfoRow('Version',    '1.0.0'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Known issues card ─────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_outlined,
                                    color: Colors.amber.shade700, size: 18),
                                const SizedBox(width: 8),
                                Text('Known Platform Issues',
                                    style: TextStyle(
                                        color:      Colors.amber.shade900,
                                        fontSize:   14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _issueRow(
                              title: 'iPhone Simulator (Apple Silicon)',
                              detail:
                                  'google_mlkit_text_recognition v0.13.1 ships '
                                  'without arm64-simulator slices. '
                                  'iOS 26+ simulator on M-series Mac fails at build time. '
                                  'App runs on macOS via Apple Vision instead.',
                            ),
                            const SizedBox(height: 8),
                            _issueRow(
                              title: 'macOS — ML Kit not supported',
                              detail:
                                  'Google ML Kit is iOS/Android only. '
                                  'macOS routes through native Swift MethodChannel '
                                  '(AppDelegate.swift) calling VNRecognizeTextRequest '
                                  'from Apple\'s Vision framework.',
                            ),
                            const SizedBox(height: 8),
                            _issueRow(
                              title: 'Swift Package Manager warning',
                              detail:
                                  'ML Kit plugins use CocoaPods, not SPM. '
                                  'This is a warning only — build succeeds. '
                                  'Will require plugin update when Flutter mandates SPM.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Enter button ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.document_scanner_outlined,
                                color: Colors.white),
                            SizedBox(width: 10),
                            Text('Open ScanLog',
                                style: TextStyle(
                                    color:      Colors.white,
                                    fontSize:   17,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text('Tap anywhere to continue',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _appInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color:      Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize:   12),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _issueRow({required String title, required String detail}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 6, height: 6,
          decoration: BoxDecoration(
            color:  Colors.amber.shade700,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, height: 1.5),
              children: [
                TextSpan(
                  text: '$title\n',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:      Colors.amber.shade900),
                ),
                TextSpan(
                  text: detail,
                  style: TextStyle(color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
