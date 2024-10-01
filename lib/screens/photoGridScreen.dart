import 'package:bookingapp/utils/AppStyles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class PhotoGridScreen extends StatelessWidget {
  final String? restaurantId;

  PhotoGridScreen({required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Εικόνες'),
        backgroundColor: Colors.white,
        leading: Ink(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
            ),
            color: Styles.primaryColor,
            onPressed: () {
              GoRouter.of(context).pop();
            },
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Δεν υπάρχουν διαθέσιμες φωτογραφίες'));
          } else {
            List<dynamic> photos = snapshot.data!['photos'];
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                String photoUrl = photos[index];
                return GestureDetector(
                  onTap: () => _showImageDialog(context, photoUrl),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            color: Colors.white,
            width: 1000,
            height: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Κλείσιμο'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
