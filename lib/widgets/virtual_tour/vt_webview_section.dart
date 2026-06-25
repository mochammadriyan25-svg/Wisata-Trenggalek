// lib/widgets/virtual_tour/vt_webview_section.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:aplikasi_wisata/core/constants/api_keys.dart';

/// WebView Virtual Tour dengan TIGA mode:
///
/// Mode 1 — image360Url (Pannellum viewer):
///   Gambar equirectangular UGC langsung dari lh3.googleusercontent.com.
///   TIDAK menggunakan Maps JavaScript API — bypass tile server limitation.
///   Cocok untuk Photo Sphere format CIHM (kontribusi pengunjung).
///
/// Mode 2 — panoId (Maps JS API):
///   Photo Sphere dengan ID AF1Qip... yang diakses via Maps JS API.
///   Cocok untuk orange dot Photo Sphere di Google Maps.
///
/// Mode 3 — lat/lng radius (Maps JS API):
///   Cari panorama terdekat dalam radius 200m via StreetViewService.
///   Cocok untuk Street View resmi Google (garis biru).
class VtWebviewSection extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? panoId;

  /// URL gambar equirectangular 360° dari Google Photos CDN.
  /// Format: https://lh3.googleusercontent.com/.../ID=w6000-h3000-k-no
  /// Jika diisi → gunakan Pannellum, tidak pakai Maps JS API.
  final String? image360Url;

  /// Arah pandang awal kamera (0–360°). Dari Firebase field initialHeading.
  /// Default 0 jika tidak diset.
  final double initialHeading;

  /// Sudut vertikal awal kamera (-90 s.d. 90°). Dari Firebase field initialPitch.
  /// Default 0 jika tidak diset.
  final double initialPitch;

  final void Function(WebViewController controller) onControllerReady;
  final VoidCallback? onPanoramaNavigated;
  final void Function(double heading)? onHeadingChanged;
  final VoidCallback? onCoverageError;

  /// Dipanggil setiap kali heading+pitch berubah (untuk live preview admin).
  /// Tidak dipakai di VirtualTourPage (halaman user) — opsional & additif.
  final void Function(double heading, double pitch)? onPovChanged; // ✅ TAMBAH

  const VtWebviewSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onControllerReady,
    this.panoId,
    this.image360Url,
    this.initialHeading = 0.0,
    this.initialPitch = 0.0,
    this.onPanoramaNavigated,
    this.onHeadingChanged,
    this.onCoverageError,
    this.onPovChanged, // ✅ TAMBAH
  });

  @override
  State<VtWebviewSection> createState() => _VtWebviewSectionState();
}

class _VtWebviewSectionState extends State<VtWebviewSection> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..addJavaScriptChannel(
            'NavChannel',
            onMessageReceived: (msg) {
              if (msg.message == 'nav') widget.onPanoramaNavigated?.call();
            },
          )
          ..addJavaScriptChannel(
            'CompassChannel',
            onMessageReceived: (msg) {
              final h = double.tryParse(msg.message);
              if (h != null) widget.onHeadingChanged?.call(h);
            },
          )
          ..addJavaScriptChannel(
            'ErrorChannel',
            onMessageReceived: (msg) {
              if (msg.message == 'no_coverage') {
                if (mounted) setState(() => _isLoading = false);
                widget.onCoverageError?.call();
              }
            },
          )
          ..addJavaScriptChannel(
            'PovChannel', // ✅ TAMBAH — khusus untuk preview admin
            onMessageReceived: (msg) {
              final parts = msg.message.split(',');
              if (parts.length == 2) {
                final h = double.tryParse(parts[0]);
                final p = double.tryParse(parts[1]);
                if (h != null && p != null) widget.onPovChanged?.call(h, p);
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                widget.onControllerReady(_controller);
              },
            ),
          )
          ..loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    final hasImage360 =
        widget.image360Url != null && widget.image360Url!.isNotEmpty;
    final hasPanoId = widget.panoId != null && widget.panoId!.isNotEmpty;
    final image360 = widget.image360Url ?? '';
    final panoId = widget.panoId ?? '';

    if (hasImage360) {
      // ── Mode 1: Pannellum viewer (UGC Photo Sphere via lh3 CDN) ──────────
      return _buildPannellumHtml(image360);
    } else {
      // ── Mode 2 & 3: Maps JavaScript API ──────────────────────────────────
      return _buildMapsHtml(hasPanoId: hasPanoId, panoId: panoId);
    }
  }

  /// HTML dengan Pannellum — render equirectangular image langsung.
  /// Tidak memerlukan Maps JavaScript API atau API key.
  String _buildPannellumHtml(String imageUrl) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport"
    content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/pannellum@2.5.6/build/pannellum.css">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    html,body{width:100%;height:100vh;overflow:hidden;background:#000}
    #pano{width:100%;height:100%}
    .pnlm-ui .pnlm-about-msg{display:none!important}
    #error{
      display:none;position:fixed;top:0;left:0;
      width:100%;height:100%;background:#0d1117;
      flex-direction:column;align-items:center;
      justify-content:center;color:white;text-align:center;padding:32px;
    }
    #error.show{display:flex}
    #error .icon{font-size:52px;margin-bottom:20px}
    #error .title{font-size:18px;font-weight:700;margin-bottom:10px;
      font-family:-apple-system,sans-serif}
    #error .desc{font-size:13px;opacity:0.55;line-height:1.6;
      font-family:-apple-system,sans-serif;max-width:280px}
  </style>
</head>
<body>
  <div id="pano"></div>
  <div id="error">
    <div class="icon">🖼️</div>
    <div class="title">Foto 360° Tidak Dapat Dimuat</div>
    <div class="desc">Gagal memuat gambar panorama.<br>Periksa image360Url di Firebase.</div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/pannellum@2.5.6/build/pannellum.js"></script>
  <script>
    var viewer;
    var lastHeading = 0;

    try {
      viewer = pannellum.viewer('pano', {
        type        : 'equirectangular',
        panorama    : '$imageUrl',
        autoLoad    : true,
        showControls: false,
        compass     : false,
        hfov        : 100,
        friction    : 0.15,
        yaw         : ${widget.initialHeading},
        pitch       : ${widget.initialPitch},
        onError     : function(err) {
          document.getElementById('error').classList.add('show');
          document.getElementById('pano').style.display = 'none';
          if (typeof ErrorChannel !== 'undefined') {
            ErrorChannel.postMessage('no_coverage');
          }
        }
      });

      // Update kompas
      setInterval(function() {
        if (!viewer) return;
        var yaw = Math.round(viewer.getYaw());
        var pitch = Math.round(viewer.getPitch());
        if (Math.abs(yaw - lastHeading) >= 5) {
          lastHeading = yaw;
          if (typeof CompassChannel !== 'undefined') {
            CompassChannel.postMessage(yaw.toString());
          }
        }
        if (typeof PovChannel !== 'undefined') {
          PovChannel.postMessage(yaw + ',' + pitch); // ✅ TAMBAH
        }
      }, 200);

    } catch(e) {
      document.getElementById('error').classList.add('show');
      document.getElementById('pano').style.display = 'none';
      if (typeof ErrorChannel !== 'undefined') {
        ErrorChannel.postMessage('no_coverage');
      }
    }

    // Fungsi yang bisa diinjeksi dari Flutter
    function startRotate(spd) {
      if (!viewer) return;
      var speed = spd || 5;
      setInterval(function() {
        viewer.setYaw(viewer.getYaw() + 0.1 * speed);
      }, 16);
    }

    function stopRotate() { /* Pannellum tidak ada stop native */ }

    function setPov(h, p, z) {
      if (!viewer) return;
      viewer.setYaw(h);
      if (p !== undefined) viewer.setPitch(p);
      if (z !== undefined) viewer.setHfov(Math.max(50, 120 - z * 20));
    }
  </script>
</body>
</html>
''';

  /// HTML dengan Maps JavaScript API (Mode 2: panoId / Mode 3: lat+lng)
  String _buildMapsHtml({required bool hasPanoId, required String panoId}) =>
      '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport"
    content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    html,body{width:100%;height:100vh;overflow:hidden;background:#0a0a0a}
    #sv{width:100%;height:100%}
    #error{
      display:none;position:fixed;top:0;left:0;
      width:100%;height:100%;background:#0d1117;
      flex-direction:column;align-items:center;
      justify-content:center;color:white;text-align:center;padding:32px;
    }
    #error.show{display:flex}
    #error .icon{font-size:52px;margin-bottom:20px}
    #error .title{font-size:18px;font-weight:700;margin-bottom:10px;
      font-family:-apple-system,sans-serif}
    #error .desc{font-size:13px;opacity:0.55;line-height:1.6;
      font-family:-apple-system,sans-serif;max-width:280px}
  </style>
</head>
<body>
  <div id="sv"></div>
  <div id="error">
    <div class="icon">🗺️</div>
    <div class="title">${hasPanoId ? "Photo Sphere Tidak Tersedia" : "Street View Tidak Tersedia"}</div>
    <div class="desc">${hasPanoId ? "Gunakan image360Url untuk UGC Photo Sphere." : "Lokasi ini belum memiliki cakupan Street View."}</div>
  </div>
  <script>
    var pano, rotInterval;
    var isInitialized = false;
    var lastHeading = -1;

    function showError() {
      document.getElementById('error').classList.add('show');
      document.getElementById('sv').style.display = 'none';
      if (typeof ErrorChannel !== 'undefined') ErrorChannel.postMessage('no_coverage');
    }

    function setupListeners() {
      pano.addListener('status_changed', function() {
        if (pano.getStatus() !== 'OK') showError();
      });
      pano.addListener('pano_changed', function() {
        if (!isInitialized) { isInitialized = true; return; }
        if (typeof NavChannel !== 'undefined') NavChannel.postMessage('nav');
      });
      pano.addListener('pov_changed', function() {
        var pov = pano.getPov();        
        var h = Math.round(pov.heading);
        if (Math.abs(h - lastHeading) >= 5) {
          lastHeading = h;
          if (typeof CompassChannel !== 'undefined') CompassChannel.postMessage(h.toString());
        }
        if (typeof PovChannel !== 'undefined') PovChannel.postMessage(h + ',' + Math.round(pov.pitch)); // ✅ TAMBAH
      });
    }

    function initSV() {
      var usePanoId = ${hasPanoId ? 'true' : 'false'};
      var panoId = '$panoId';

      if (usePanoId) {
        pano = new google.maps.StreetViewPanorama(
          document.getElementById('sv'), {
            pano    : panoId,
            pov     : { heading: ${widget.initialHeading}, pitch: ${widget.initialPitch} },
            zoom    : 1,
            visible : true,
            addressControl        : false,
            fullscreenControl     : false,
            panControl            : false,
            zoomControl           : false,
            enableCloseButton     : false,
            showRoadLabels        : false,
            linksControl          : true,
            clickToGo             : true,
            motionTracking        : false,
            motionTrackingControl : false
          }
        );
        setupListeners();
      } else {
        // Cari dulu panorama terdekat via service. SETELAH dapat panoId,
        // baru buat StreetViewPanorama dengan pano + pov SEKALIGUS di
        // constructor — pola yang sama dengan mode panoId yang sudah benar.
        // Membuat panorama kosong lalu setPano() belakangan menyebabkan
        // POV (heading/pitch) di-reset ke orientasi default panorama.
        var sv = new google.maps.StreetViewService();
        sv.getPanorama({
          location : { lat: ${widget.latitude}, lng: ${widget.longitude} },
          radius   : 200,
          source   : google.maps.StreetViewSource.DEFAULT
        }, function(data, status) {
          if (status === 'OK') {
            pano = new google.maps.StreetViewPanorama(
              document.getElementById('sv'), {
                pano    : data.location.pano,
                pov     : { heading: ${widget.initialHeading}, pitch: ${widget.initialPitch} },
                zoom    : 1,
                visible : true,
                addressControl        : false,
                fullscreenControl     : false,
                panControl            : false,
                zoomControl           : false,
                enableCloseButton     : false,
                showRoadLabels        : false,
                linksControl          : true,
                clickToGo             : true,
                motionTracking        : false,
                motionTrackingControl : false
              }
            );
            setupListeners();
            // Jaga-jaga: paksa POV sekali lagi setelah tiles selesai dimuat,
            // karena beberapa panorama me-reset orientasi saat tile load.
            google.maps.event.addListenerOnce(pano, 'tiles_loaded', function() {
              pano.setPov({
                heading : ${widget.initialHeading},
                pitch   : ${widget.initialPitch}
              });
            });
          }
          else showError();
        });
      }
    }

    function startRotate(spd) {
      stopRotate();
      rotInterval = setInterval(function() {
        var p = pano.getPov();
        pano.setPov({heading:(p.heading+(spd||0.2))%360, pitch:p.pitch});
      }, 16);
    }
    function stopRotate() {
      if (rotInterval) { clearInterval(rotInterval); rotInterval = null; }
    }
    function setPov(h,p,z) {
      stopRotate();
      pano.setPov({heading:h, pitch:p||0});
      if (z !== undefined) pano.setZoom(z);
    }
    function disableNavigation() {
      pano.setOptions({linksControl:false, clickToGo:false});
    }
  </script>
  <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=${ApiKeys.googleMapsJs}&callback=initSV">
  </script>
</body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Memuat Virtual Tour...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
