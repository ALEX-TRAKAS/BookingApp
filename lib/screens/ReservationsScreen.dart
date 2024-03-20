import 'package:flutter/material.dart';
import 'package:bookingapp/services/databaseFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

enum ReservationStatus { canceled, confirmed, pending, attended }

class _ReservationsScreenState extends State<ReservationsScreen> {
  Future<List<Map<String, dynamic>>>? _reservations;
  final user = FirebaseAuth.instance.currentUser!;
  final db = databaseFunctions();

  @override
  void initState() {
    print('Init state of ReservationScreen called.');
    super.initState();
    _reservations = db.getAllReservations(user.uid);
  }

  Future<void> _cancelReservation(String reservationId) async {
    try {
      print('Canceling reservation with ID: $reservationId');
      ReservationStatus status = ReservationStatus.canceled;
      await db.updateReservationStatus(
        user.uid,
        reservationId,
        status.toString(),
      );

      setState(() {
        // Update the list of reservations
        _reservations = db.getAllReservations(user.uid);
      });
    } catch (e) {
      print('Error canceling reservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Κρατήσεις'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Δεν υπάρχουν κρατήσεις.'));
          } else {
            List<Map<String, dynamic>> reservations = snapshot.data!;
            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final item = reservations[index];

                return ListTile(
                  title: Text(item['reservationStatus']),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      _cancelReservation(item['id'].toString());
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
