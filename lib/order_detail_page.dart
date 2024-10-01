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
        imageProvider: NetworkImage(fotoURL),
      ),
    );
  }
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<Map<String, dynamic>> _fotoProgressHistory = [];
  final ApiService _apiService = ApiService();
  VideoPlayerController? _videoController;
  List<Map<String, dynamic>> _fotoProduk = [];

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
    _loadFotoProgressHistory();
    _loadFotoProduk();
  }

  Future<void> _loadOrderItems() async {
    final items = await _apiService.getOrderItemsByOrderId(widget.order.id);
    debugPrint('ini hasil nya : $items');
    setState(() {});
  }

  Future<void> _loadFotoProgressHistory() async {
    final history = await _apiService.getFotoProgressHistory(widget.order.id);
    setState(() {
      _fotoProgressHistory = history;
    });
    debugPrint('$widget.order.videoProgressURL');
    if (_fotoProgressHistory.isEmpty) {
      debugPrint('Tidak ada data riwayat foto progress.');
    } else {
      debugPrint(
          'Ada ${_fotoProgressHistory.length} entri riwayat foto progress.');
    }
  }

  Future<void> _loadFotoProduk() async {
    final history = await _apiService.getFotoProduk(widget.order.id);
    setState(() {
      _fotoProduk = history as List<Map<String, dynamic>>;
    });
    debugPrint('$widget.order.fotoProdukUrl');
    if (_fotoProduk.isEmpty) {
      debugPrint('Tidak ada data riwayat foto progress.');
    } else {
      debugPrint(
          'Ada ${_fotoProduk.length} entri riwayat foto progress.');
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
    final DateTime date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    final DateFormat formatter = DateFormat('yyyy-MM-dd | HH:mm:ss');
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
        backgroundColor : const Color.fromARGB(255, 154, 60, 149),
        titleTextStyle: const TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),     
     
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Pelanggan: ${widget.order.customerName}',
                  style: const TextStyle(fontSize: 18)),
              Text('Total Harga: ${widget.order.totalPrice}',
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
              Text('Jumlah: ${widget.order.quantity}',
                  style: const TextStyle(fontSize: 18)),
              Text('harga: ${widget.order.price}',
                  style: const TextStyle(fontSize: 18)),

             const SizedBox(height: 16),
            const Text('Foto Produk:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (widget.order.fotoProdukURL != null && widget.order.fotoProdukURL!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                          fotoURL: widget.order.fotoProdukURL!),
                    ),
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 200, // Sesuaikan tinggi sesuai kebutuhan
                  child: Image.network(
                    widget.order.fotoProdukURL!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              const Text(
                'Foto produk tidak tersedia',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              

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
                       
                      ],
                    ),
                  );
                },
              ),

                   const Text('Video Progress:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 10),
              if (widget.order.videoProgressURL != null)
                GestureDetector(
                  onTap: () {
                    _videoController = VideoPlayerController.networkUrl(
                      Uri.parse(widget.order.videoProgressURL!)
                    )..initialize().then((_) {
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
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const SizedBox(
                          width: 160,
                          height: 90,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                )else
              const Text(
                'video progress tidak tersedia',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
