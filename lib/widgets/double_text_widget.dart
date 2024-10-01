import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/name_route.dart';
import '../utils/AppStyles.dart';

class AppDoubleTextWidget extends StatelessWidget {
  final String bigText;
  final String smallText;
  const AppDoubleTextWidget(
      {super.key, required this.bigText, required this.smallText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          bigText,
          style: Styles.headLineStyle2,
        ),
        InkWell(
          onTap: () {
            if (bigText == "Δημοφιλή εστιατόρια") {
              context.pushNamed(
                homeSearchNameRoute,
                queryParameters: {
                  'filterType': 'Δημοφιλή εστιατόρια',
                },
              );
            }
            if (bigText == "Πλησιέστερα") {
              context.pushNamed(
                homeSearchNameRoute,
                queryParameters: {
                  'filterType': 'Πλησιέστερα',
                },
              );
            }
          },
          child: Text(
            smallText,
            style: Styles.textStyle.copyWith(color: Styles.primaryColor),
          ),
        ),
      ],
    );
  }
}
