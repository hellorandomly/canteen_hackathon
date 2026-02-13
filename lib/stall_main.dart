import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:async';

// ==========================================
// 1. MAIN STORE APP
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StoreApp());
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniCanteen Store',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const StoreDashboard(),
    );
  }
}

// ==========================================
// 2. STORE DASHBOARD SCREEN
// ==========================================

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({super.key});
  @override
  State<StoreDashboard> createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  bool isStoreOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("The Grill & Griddle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            Text("Store Dashboard", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isStoreOpen ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isStoreOpen ? Colors.green : Colors.red),
            ),
            child: Row(
              children: [
                Text(isStoreOpen ? "OPEN" : "CLOSED",
                    style: TextStyle(fontWeight: FontWeight.bold, color: isStoreOpen ? Colors.green : Colors.red)),
                Switch(
                  value: isStoreOpen,
                  onChanged: (val) => setState(() => isStoreOpen = val),
                  activeColor: Colors.green,
                ),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================================
            // REAL-TIME ORDERS LIST
            // ===========================================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // LISTEN to the 'orders' collection
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Connection Error"));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final orders = snapshot.data!.docs;

                  if (orders.isEmpty) return const Center(child: Text("No Active Orders"));

                  // Simple Stats
                  int pendingCount = orders.where((o) => o['status'] == 'preparing').length;
                  int readyCount = orders.where((o) => o['status'] == 'ready').length;

                  return Column(
                    children: [
                      // Stats Bar
                      Row(
                        children: [
                          _buildStatCard("Pending", pendingCount, Colors.orange),
                          const SizedBox(width: 12),
                          _buildStatCard("Ready", readyCount, Colors.green),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Incoming Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                      ),
                      const SizedBox(height: 12),

                      // The List
                      Expanded(
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            var data = orders[index].data() as Map<String, dynamic>;
                            String docId = orders[index].id;

                            // Safe Data Handling
                            String token = data['token'] ?? "Q-000";
                            String status = data['status'] ?? "preparing";
                            bool isTakeaway = data['isTakeaway'] ?? false;

                            // Calculate Time Ago
                            String timeAgo = "Just now";
                            if (data['timestamp'] != null) {
                              Timestamp t = data['timestamp'];
                              int mins = DateTime.now().difference(t.toDate()).inMinutes;
                              timeAgo = "$mins mins ago";
                            }

                            return _buildLiveOrderCard(docId, token, status, isTakeaway, timeAgo);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveOrderCard(String docId, String token, String status, bool isTakeaway, String timeAgo) {
    bool isReady = status == 'ready';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isReady ? Colors.green : Colors.grey.shade200, width: isReady ? 2 : 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QUEUE TOKEN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text(token, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),

                // ORDER INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isTakeaway ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(isTakeaway ? Icons.shopping_bag_outlined : Icons.restaurant,
                                    size: 14, color: isTakeaway ? Colors.red : Colors.green),
                                const SizedBox(width: 4),
                                Text(isTakeaway ? "TAKEAWAY" : "EAT-IN",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isTakeaway ? Colors.red : Colors.green)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(timeAgo, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Fake items for demo (since we didn't save full list yet)
                      const Text("• Mixed Rice Set", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: isReady
                  ? OutlinedButton.icon(
                onPressed: () {
                  // DELETE or ARCHIVE order when collected
                  FirebaseFirestore.instance.collection('orders').doc(docId).delete();
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                label: const Text("Complete & Remove"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
              )
                  : FilledButton(
                onPressed: () {
                  // MARK READY in Cloud
                  FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'ready'});
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("MARK AS READY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            Text("$count", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}