import 'package:flutter/material.dart';
import '../models/productModel.dart';

class OrderSuccessPage extends StatefulWidget {
  final List<Product> shoppingList;
  final double subtotal;
  final double totalDiscount;
  final double totalPrice;

  const OrderSuccessPage({
    super.key,
    required this.shoppingList,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalPrice,
  });

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOutCirc),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sipariş Detayı",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildStatusBar(),
                  const SizedBox(height: 12),
                  _buildProductList(),
                  const SizedBox(height: 12),
                  _buildPriceSummary(),
                  const SizedBox(height: 12),
                  _buildDeliveryInfo(),
                  const SizedBox(height: 24),
                  _buildButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return _buildCard(
      title: "ÜRÜNLER",
      child: Column(
        children: widget.shoppingList.map((product) {
          final isLast = product == widget.shoppingList.last;
          final price = product.price ?? 0.0;
          final discountPercent = product.discountPercentage ?? 0.0;
          final discountedPrice = price - (price * (discountPercent / 100));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Ürün görseli
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.thumbnail ?? "",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.black38,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Ürün adı ve kategori
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (discountPercent > 0)
                            Text(
                              "${product.category ?? ""} · %${discountPercent.toStringAsFixed(0)} indirim",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            )
                          else
                            Text(
                              product.category ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // İndirimli fiyat
                    Text(
                      "\$${discountedPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return _buildCard(
      title: "FİYAT ÖZETİ",
      child: Column(
        children: [
          _priceRow(
            "Ara Toplam",
            "\$${widget.subtotal.toStringAsFixed(2)}",
            false,
          ),
          _priceRow(
            "İndirim",
            "-\$${widget.totalDiscount.toStringAsFixed(2)}",
            true,
            isDiscount: true,
          ),
          _priceRow("Kargo", "Ücretsiz", true, isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Toplam",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "\$${widget.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          // Animasyonlu Tik
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (_, __) => Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.withOpacity(
                        0.3 * _checkAnimation.value,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                child: AnimatedBuilder(
                  animation: _checkAnimation,
                  builder: (_, __) => CustomPaint(
                    painter: _CheckmarkPainter(_checkAnimation.value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Siparişiniz Alındı!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ödemeniz başarıyla işlendi.\nSiparişiniz hazırlanıyor.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFBBF24), width: 0.8),
            ),
            child: const Text(
              "#ORD-20260408-7741",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final steps = [
      {
        "icon": Icons.check_circle_outline,
        "label": "Onaylandı",
        "active": true,
      },
      {
        "icon": Icons.inventory_2_outlined,
        "label": "Hazırlanıyor",
        "active": true,
      },
      {
        "icon": Icons.local_shipping_outlined,
        "label": "Kargoda",
        "active": false,
      },
      {"icon": Icons.home_outlined, "label": "Teslim", "active": false},
    ];

    return _buildCard(
      title: "SİPARİŞ DURUMU",
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          children: List.generate(steps.length, (i) {
            final step = steps[i];
            final isActive = step["active"] as bool;
            final isLast = i == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? Colors.orange
                                : const Color(0xFFF0F0F0),
                          ),
                          child: Icon(
                            step["icon"] as IconData,
                            size: 16,
                            color: isActive ? Colors.white : Colors.black26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step["label"] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isActive ? Colors.orange : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: isActive && (steps[i + 1]["active"] as bool)
                            ? Colors.orange
                            : (isActive
                                  ? Colors.orange.withOpacity(0.3)
                                  : const Color(0xFFE0E0E0)),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value,
    bool hasDivider, {
    bool isDiscount = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDiscount ? const Color(0xFF16A34A) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (hasDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final infos = [
      {
        "icon": Icons.location_on_outlined,
        "label": "Teslimat Adresi",
        "value": "Battalgazi Mah. Atatürk Cad. No:12, Malatya",
        "mono": false,
      },
      {
        "icon": Icons.credit_card_outlined,
        "label": "Ödeme Yöntemi",
        "value": "Visa •••• 4291",
        "mono": false,
      },
      {
        "icon": Icons.local_shipping_outlined,
        "label": "Tahmini Teslimat",
        "value": "11 – 14 Nisan 2026",
        "mono": false,
      },
      {
        "icon": Icons.confirmation_number_outlined,
        "label": "Kargo Takip No",
        "value": "TK-8843-2026-MLTY",
        "mono": true,
      },
    ];

    return _buildCard(
      title: "TESLİMAT & ÖDEME",
      child: Column(
        children: infos.map((info) {
          final isLast = info == infos.last;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      info["icon"] as IconData,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info["label"] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            info["value"] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontFamily: (info["mono"] as bool)
                                  ? 'monospace'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Alışverişe Devam Et",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 14,
              right: 16,
              bottom: 0,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
                letterSpacing: 0.8,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.27, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.67)
      ..lineTo(size.width * 0.73, size.height * 0.35);

    final pathMetrics = path.computeMetrics().first;
    final drawn = pathMetrics.extractPath(0, pathMetrics.length * progress);
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}
