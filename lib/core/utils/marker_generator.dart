import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  
  // 1. FUNGSI LAMA (Jembatan untuk marker yang tegak lurus/normal)
  static Future<BitmapDescriptor> createCustomMarker(String text, Color color) async {
    // Memanggil fungsi utama dengan sudut 0 derajat (tegak)
    return createFannedMarker(
      text: text, 
      color: color, 
      angleDegrees: 0
    );
  }

  // 2. FUNGSI UTAMA (Untuk marker yang bisa miring/mekar seperti kipas)
  // Tambahkan parameter stemLength dengan nilai default 70
  static Future<BitmapDescriptor> createFannedMarker({
    required String text,
    required Color color,
    required double angleDegrees,
    bool isClusterParent = false,
    double stemLength = 70.0, // <--- TAMBAHAN DI SINI
  }) async {
    const double W = 200; 
    const double H = 180; // <--- TINGGI KANVAS DIPERBESAR SEDIKIT JAGA-JAGA
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double tipX = W / 2;
    final double tipY = H - 10; 

    final double angleRad = angleDegrees * (math.pi / 180);

    canvas.save();
    canvas.translate(tipX, tipY); 
    canvas.rotate(angleRad);      

    // Ganti angka 70 yang statis dengan variabel stemLength
    final double L = stemLength;  // <--- UBAH DI SINI
    final double R = isClusterParent ? 45 : 35;  

    Path path = Path();
    path.moveTo(0, 0); 
    path.lineTo(-R * 0.85, -L + R * 0.5); 
    path.arcToPoint(
      Offset(R * 0.85, -L + R * 0.5),
      radius: Radius.circular(R),
      largeArc: true,
      clockwise: true,
    ); 
    path.close();

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(path, shadowPaint);

    final Paint paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isClusterParent ? 5.0 : 3.5;
    canvas.drawPath(path, borderPaint);

    canvas.restore(); 

    final double textCx = tipX + (L * math.sin(angleRad));
    final double textCy = tipY - (L * math.cos(angleRad));

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text,
      style: TextStyle(fontSize: R * 0.9, color: Colors.white, fontWeight: FontWeight.bold),
    );
    painter.layout();
    painter.paint(canvas, Offset(textCx - (painter.width / 2), textCy - (painter.height / 2)));

    final img = await pictureRecorder.endRecording().toImage(W.toInt(), H.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
}