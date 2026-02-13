import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'dart:math';

// ==========================================
// 1. DATA MODELS & CONSTANTS
// ==========================================

class Stall {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int baseWaitTime;
  final List<Map<String, dynamic>> menu;

  const Stall({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.baseWaitTime,
    required this.menu,
  });
}

const List<Stall> universityStalls = [
  Stall(
    id: 's1',
    name: "The Grill & Griddle",
    description: "Flame-grilled perfections.",
    imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=800",
    rating: 4.8,
    baseWaitTime: 8,
    menu: [
      {"name": "Crispy Chicken Cutlet", "price": 5.50, "desc": "Golden fried w/ sides"},
      {"name": "Grilled Fish w/ Herbs", "price": 6.20, "desc": "Lemon butter sauce"},
      {"name": "Cheesy Beef Burger", "price": 4.80, "desc": "100% Angus Beef"},
    ],
  ),
  Stall(
    id: 's2',
    name: "Noodle Network",
    description: "Authentic Asian flavors.",
    imageUrl: "https://images.unsplash.com/photo-1552611052-33e04de081de?w=800",
    rating: 4.5,
    baseWaitTime: 4,
    menu: [
      {"name": "Signature Laksa", "price": 4.50, "desc": "Spicy coconut broth"},
      {"name": "Minced Meat Noodles", "price": 3.80, "desc": "Springy noodles"},
    ],
  ),
  Stall(
    id: 's3',
    name: "Green Greens",
    description: "Healthy bowls & salads.",
    imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800",
    rating: 4.9,
    baseWaitTime: 3,
    menu: [
      {"name": "Protein Bowl", "price": 6.80, "desc": "Chicken breast & quinoa"},
      {"name": "Caesar Salad", "price": 4.50, "desc": "Fresh romaine lettuce"},
    ],
  ),
];

// ==========================================
// 2. MAIN APP & THEME
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CanteenApp());
}

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniCanteen',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00),
          secondary: const Color(0xFF2D3436),
          surface: const Color(0xFFF9F9F9),
        ),
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 3. LOGIN SCREEN
// ==========================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _sidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(height: 300, width: 300, decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -50, left: -50,
            child: Container(height: 200, width: 200, decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle)),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fastfood_rounded, size: 64, color: Color(0xFFFF6B00)),
                  const SizedBox(height: 20),
                  const Text("UniCanteen", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const Text("Skip the queue, eat better.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 50),

                  TextField(
                    controller: _sidController,
                    decoration: InputDecoration(
                      labelText: "Student ID",
                      hintText: "e.g. 1005523",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_sidController.text.isNotEmpty) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(studentId: _sidController.text)));
                      }
                    },
                    child: const Text("Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. HOME SCREEN
// ==========================================

class HomeScreen extends StatelessWidget {
  final String studentId;
  const HomeScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF9F9F9),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text("Hello, $studentId 👋", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final stall = universityStalls[index];
                  final int peopleInQueue = Random().nextInt(8) + 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MenuScreen(stall: stall, currentQueue: peopleInQueue))),
                      child: Column(
                        children: [
                          Hero(
                            tag: stall.id,
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                image: DecorationImage(image: NetworkImage(stall.imageUrl), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(stall.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Row(children: [const Icon(Icons.star, size: 14, color: Colors.orange), Text(" ${stall.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(stall.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.people_outline, size: 16, color: Colors.grey.shade500),
                                    Text(" $peopleInQueue in queue", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    const Spacer(),
                                    Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                                    Text(" ~${peopleInQueue * stall.baseWaitTime} mins", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: universityStalls.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. MENU SCREEN
// ==========================================

class MenuScreen extends StatefulWidget {
  final Stall stall;
  final int currentQueue;
  const MenuScreen({super.key, required this.stall, required this.currentQueue});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<String, int> cart = {};
  bool isTakeaway = false;

  double get _cartTotal {
    double total = 0;
    cart.forEach((dishName, qty) {
      final dish = widget.stall.menu.firstWhere((d) => d['name'] == dishName);
      total += (dish['price'] as double) * qty;
    });
    if (isTakeaway && total > 0) total += 0.30;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(widget.stall.name, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    background: Hero(
                      tag: widget.stall.id,
                      child: Image.network(widget.stall.imageUrl, fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.1), colorBlendMode: BlendMode.darken),
                    ),
                  ),
                  leading: const BackButton(color: Colors.white),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          _buildToggleOption("Eat In", !isTakeaway),
                          _buildToggleOption("Takeaway (+\$0.30)", isTakeaway),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final dish = widget.stall.menu[index];
                      final qty = cart[dish['name']] ?? 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dish['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(dish['desc'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text("\$${dish['price'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: () => setState(() => qty > 0 ? cart[dish['name']] = qty - 1 : null)),
                                  Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(icon: const Icon(Icons.add, size: 18, color: Colors.orange), onPressed: () => setState(() => cart[dish['name']] = qty + 1)),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: widget.stall.menu.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _cartTotal > 0 ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))]),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text("\$${_cartTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                if(isTakeaway) const Text("incl. surcharge", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: const Color(0xFF2D3436),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Pay Now"),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(stall: widget.stall, total: _cartTotal, initialQueue: widget.currentQueue, isTakeaway: isTakeaway))),
            ),
          ],
        ),
      ) : null,
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isTakeaway = text.contains("Takeaway")),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(text, textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }
}

// ==========================================
// 6. PAYMENT & RECEIPT SCREEN
// ==========================================

class PaymentScreen extends StatelessWidget {
  final Stall stall;
  final double total;
  final int initialQueue;
  final bool isTakeaway; // Added this to pass data

  const PaymentScreen({
    super.key,
    required this.stall,
    required this.total,
    required this.initialQueue,
    this.isTakeaway = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  const Text("Scan to Pay", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Image.network("https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PAYNOW_DEMO", height: 200),
                  const SizedBox(height: 20),
                  Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("PayNow • DBS PayLah!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () {
                        // ===========================================
                        // FIREBASE INTEGRATION START
                        // ===========================================
                        final String token = "Q-${Random().nextInt(999)}";

                        // 1. Send Order to Cloud
                        FirebaseFirestore.instance.collection('orders').add({
                          'token': token,
                          'stallName': stall.name,
                          'totalPrice': total,
                          'isTakeaway': isTakeaway,
                          'status': 'preparing', // Initial status
                          'timestamp': FieldValue.serverTimestamp(), // To sort by time
                          'items': ['Demo Item 1', 'Demo Item 2'] // You can map real cart items here later
                        });

                        // 2. Navigate to Receipt
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => OrderStatusScreen(stall: stall, token: token, queueAhead: initialQueue)),
                              (route) => false,
                        );
                        // ===========================================
                        // FIREBASE INTEGRATION END
                        // ===========================================
                      },
                      child: const Text("I Have Paid"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusScreen extends StatelessWidget {
  final Stall stall;
  final String token;
  final int queueAhead;
  const OrderStatusScreen({super.key, required this.stall, required this.token, required this.queueAhead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("Order Confirmed!", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Text("Queue Number", style: TextStyle(color: Colors.grey.shade400, letterSpacing: 1)),
                  Text(token, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black)),
                  const Divider(height: 40),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Stall"), Text(stall.name, style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Ahead"), Text("$queueAhead people", style: const TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Wait"), Text("~${stall.baseWaitTime * queueAhead} mins", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))]),
                ],
              ),
            ),

            const Spacer(),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20)),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("SCAN COUNTER QR TO COLLECT"),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CanteenApp()));
              },
            ),
          ],
        ),
      ),
    );
  }
}