import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'order_model.dart';
import 'api_service.dart';
import 'package:video_player/video_player.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class FullScreenImage extends StatelessWidget {
  static const String baseUrl = 'http://10.0.2.2:5500';
  final String fotoURL;
  const FullScreenImage({super.key, required this.fotoURL});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Progress'),
        backgroundColor: Colors.black,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(fotoURL), // Menggunakan NetworkImage untuk menampilkan gambar dari URL
      ),
    );
  }
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<Map<String, dynamic>> _fotoProgressHistory = [];
  final ApiService _apiService = ApiService();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
    _loadFotoProgressHistory();
  }

  Future<void> _loadOrderItems() async {
    final items = await _apiService.getOrderItemsByOrderId(widget.order.id);
    debugPrint('$items');
    setState(() {
    });
  }

  Future<void> _loadFotoProgressHistory() async {
    final history = await _apiService.getFotoProgressHistory(widget.order.id);
    setState(() {
      _fotoProgressHistory = history;
    });
    if (_fotoProgressHistory.isEmpty) {
      debugPrint('Tidak ada data riwayat foto progress.');
    } else {
      debugPrint(
          'Ada ${_fotoProgressHistory.length} entri riwayat foto progress.');
    }
  }

  String intlDate(DateTime date) {
    final format = DateFormat('dd MMMM yyyy, hh:mm a');
    return format.format(date);
  }
  
  String formatDateFromTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      timestamp = int.tryParse(timestamp) ?? 0;
    }
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(date);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Pelanggan: ${widget.order.customerName}',
                  style: const TextStyle(fontSize: 18)),
              Text('Tanggal Order: ${intlDate(widget.order.orderDate)}',
                  style: const TextStyle(fontSize: 18)),
              Text('Status: ${widget.order.status}',
                  style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 10),
              const Text('Item Order:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),
              Text('Nama Product: ${widget.order.productName}',
                  style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 16),
              const Text('Riwayat Foto Progress:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fotoProgressHistory.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final fotoURL = _fotoProgressHistory[index]['newFotoProgressURL'];
                  final videoURL = _fotoProgressHistory[index]['newVideoProgressURL'];
                  final isSuccess = fotoURL != null || videoURL != null;
                  dynamic timestamp = _fotoProgressHistory[index]['updateDate'];
                  final String formattedDate = formatDateFromTimestamp(timestamp);

                  return ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle,
                            color: isSuccess ? Colors.green : Colors.red,
                            size: 16),
                        if (index < _fotoProgressHistory.length - 1)
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    title: Text(
                        '$formattedDate - ${_fotoProgressHistory[index]['status']} '),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (fotoURL != null)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenImage(fotoURL: fotoURL),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(fotoURL),
                            ),
                          ),
                        if (videoURL != null)
                          GestureDetector(
                            onTap: () {
                              // ignore: deprecated_member_use
                              _videoController = VideoPlayerController.network(videoURL)
                                ..initialize().then((_) {
                                  setState(() {});
                                  _videoController!.play();
                                });
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: AspectRatio(
                                    aspectRatio: _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              );
                            },
                            child: const Icon(Icons.play_circle_fill, size: 80),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
