// import 'package:bookingapp/screens/reservationScreenState.dart';
// import 'package:flutter/material.dart';

// class ReservationDialog extends StatefulWidget {
//   final List<Map<String, dynamic>> initialRestaurants;
//   final void Function(List<Map<String, dynamic>> selectedRestaurants)?
//       onSelectedRestaurants;

//   const ReservationDialog({
//     super.key,
//     required this.initialRestaurants,
//     this.onSelectedRestaurants,
//   });

//   @override
//   _ReservationDialogState createState() => _ReservationDialogState();
// }

// class _ReservationDialogState extends State<ReservationDialog> {
//   List<Map<String, dynamic>>? _selectedRestaurants;

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Expanded(
//         child: Dialog(
//           insetPadding:
//               const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
//           backgroundColor: Colors.transparent,
//           child: Container(
//             alignment: Alignment.bottomCenter,
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             child: ReservationScreen(
//               initialRestaurants: widget.initialRestaurants,
//               onSelectedRestaurants: (selectedRestaurants) {
//                 setState(() {
//                   _selectedRestaurants = selectedRestaurants;
//                 });
//                 if (widget.onSelectedRestaurants != null) {
//                   widget.onSelectedRestaurants!(_selectedRestaurants!);
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
