import 'package:bookingapp/utils/AppStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class webFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Styles.secondaryColor,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEWSLETTER',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Κάνε εγγραφή για να μαθαίνεις πρώτος προσφορές',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Εισάγετε το email σας',
                            border: InputBorder.none,
                          ),
                          validator: (value) {},
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // If the screen width is less than 600, use a Column layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Replace with your logo asset
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ΕΤΑΙΡΕΙΑ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Σχετικά με εμάς\nΌροι χρήσης\nΕπικοινωνία\nBlogs',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ΥΠΟΣΤΗΡΙΞΗ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Για επιχειρήσεις εστίασης\nΠώς λειτουργεί\nΓιατί να επιλέξετε εμάς\nΣυχνές ερωτήσεις',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ΕΠΙΚΟΙΝΩΝΙΑ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Τηλέφωνο: 1234567890\nEmail: reserveat@email.com\nLocation: Θεσσαλονίκη , Ελλάδα',
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.facebook,
                                color: Colors.black),
                            SizedBox(width: 10),
                            Icon(FontAwesomeIcons.instagram,
                                color: Colors.black),
                            SizedBox(width: 10),
                            Icon(FontAwesomeIcons.whatsapp,
                                color: Colors.black),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // If the screen width is greater than or equal to 600, use a Row layout
                return Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Replace with your logo asset
                      height: 200,
                    ),
                    const SizedBox(width: 50),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ΕΤΑΙΡΕΙΑ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Σχετικά με εμάς\nΌροι χρήσης\nΕπικοινωνία\nBlogs',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ΥΠΟΣΤΗΡΙΞΗ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Για επιχειρήσεις εστίασης\nΠώς λειτουργεί\nΓιατί να επιλέξετε εμάς\nΣυχνές ερωτήσεις',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ΕΠΙΚΟΙΝΩΝΙΑ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Τηλέφωνο: 1234567890\nEmail: reserveat@email.com\nLocation: Θεσσαλονίκη , Ελλάδα',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(FontAwesomeIcons.facebook,
                                            color: Colors.black),
                                        SizedBox(width: 10),
                                        Icon(FontAwesomeIcons.instagram,
                                            color: Colors.black),
                                        SizedBox(width: 10),
                                        Icon(FontAwesomeIcons.whatsapp,
                                            color: Colors.black),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        const Divider(color: Color(0xFFE0E2E6)),
        Container(
          color: Colors.white,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2024 Reserve-Eat | All rights reserved',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Created by Reserve-Eat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
