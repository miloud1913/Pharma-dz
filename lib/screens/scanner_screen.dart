import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/database_service.dart';
import '../models/medicament.dart';
import 'detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? _controller;
  bool _isScanning = false;
  bool _torchOn = false;
  String? _lastScanned;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isScanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final value = barcode.rawValue!;
    if (value == _lastScanned) return;

    setState(() {
      _isScanning = true;
      _lastScanned = value;
    });

    await _controller?.stop();

    final med = await DatabaseService.instance.findByBarcode(value);

    if (!mounted) return;

    if (med != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(medicament: med)),
      );
    } else {
      _showNotFoundDialog(value);
    }

    setState(() => _isScanning = false);
    await _controller?.start();
  }

  void _showNotFoundDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Médicament non trouvé'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aucun médicament trouvé pour ce code :'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un médicament'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            tooltip: 'Torche',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller?.switchCamera(),
            tooltip: 'Changer caméra',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          // Overlay with scan frame
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: Container(),
          ),
          // Bottom hint
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  if (_isScanning)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    const Icon(Icons.qr_code_scanner,
                        color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    _isScanning
                        ? 'Recherche en cours...'
                        : 'Placez le code-barres dans le cadre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Codes-barres EAN, QR, et numéros d\'enregistrement',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Top center scan line animation
          if (!_isScanning)
            const _ScanLine(),
        ],
      ),
    );
  }
}

class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.25, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).size.height * _animation.value,
          left: MediaQuery.of(context).size.width * 0.15,
          right: MediaQuery.of(context).size.width * 0.15,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF006633).withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final frameWidth = size.width * 0.7;
    final frameHeight = frameWidth * 0.6;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;
    final rect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

    // Dark overlay with hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Corner lines
    final linePaint = Paint()
      ..color = const Color(0xFF006633)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLen = 24.0;
    final r = 12.0;

    // Top-left
    canvas.drawLine(
        Offset(left + r, top), Offset(left + r + cornerLen, top), linePaint);
    canvas.drawLine(
        Offset(left, top + r), Offset(left, top + r + cornerLen), linePaint);
    // Top-right
    canvas.drawLine(Offset(left + frameWidth - r, top),
        Offset(left + frameWidth - r - cornerLen, top), linePaint);
    canvas.drawLine(Offset(left + frameWidth, top + r),
        Offset(left + frameWidth, top + r + cornerLen), linePaint);
    // Bottom-left
    canvas.drawLine(Offset(left + r, top + frameHeight),
        Offset(left + r + cornerLen, top + frameHeight), linePaint);
    canvas.drawLine(Offset(left, top + frameHeight - r),
        Offset(left, top + frameHeight - r - cornerLen), linePaint);
    // Bottom-right
    canvas.drawLine(Offset(left + frameWidth - r, top + frameHeight),
        Offset(left + frameWidth - r - cornerLen, top + frameHeight),
        linePaint);
    canvas.drawLine(Offset(left + frameWidth, top + frameHeight - r),
        Offset(left + frameWidth, top + frameHeight - r - cornerLen),
        linePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
