import 'package:bookingapp/routes/name_route.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../utils/applayout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/appstyles.dart';

class restaurantsTileWide extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  const restaurantsTileWide({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final size = AppLayout.getSize(context);

    return InkWell(
      onTap: () {
        //route to detailed restaurant screen pushing with the restaurant id or name???
        context.pushNamed(restaurantsDetailedScreenNameRoute,
            queryParameters: {'restaurantId': restaurant['id'].toString()});
      },
      child: Container(
        width: size.width * 1.0,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.only(
          right: 17,
          top: 5,
        ),
        decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(
                color: Color(0xFF0F9B0F), width: 0.1, style: BorderStyle.solid),
            left: BorderSide(
                color: Color(0xFF0F9B0F), width: 0.1, style: BorderStyle.solid),
            bottom: BorderSide(
                color: Color(0xFF0F9B0F), width: 1.0, style: BorderStyle.solid),
            right: BorderSide(
                color: Color(0xFF0F9B0F), width: 0.1, style: BorderStyle.solid),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              height: 150,
              width: 119,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Styles.primaryColor,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    restaurant['mainPhoto'],
                  ),
                ),
              ),
            ),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(10),
                Text(
                  restaurant['name'],
                  style:
                      Styles.headLineStyle2.copyWith(color: Styles.textColor),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_sharp,
                      size: 25.0,
                      color: Color(0xFF0F9B0F),
                    ),
                    Text(
                      '${restaurant['Location']['city']}',
                      style: Styles.headLineStyle2
                          .copyWith(color: Styles.textColor),
                    ),
                  ],
                ),
                const Gap(5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBar.builder(
                      initialRating: (restaurant['rating'] as num).toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 25.0,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Color(0xFF0F9B0F),
                      ),
                      ignoreGestures: true,
                      onRatingUpdate: (double value) {},
                    ),
                    const Gap(2),
                    Text(
                      '(${(restaurant['rating'] as num).toDouble().toString()})',
                      style: Styles.headLineStyle2
                          .copyWith(color: Styles.textColor),
                    ),
                  ],
                ),
                const Gap(5),
                Text(
                  restaurant['cuisine'],
                  style:
                      Styles.headLineStyle3.copyWith(color: Styles.textColor),
                ),
                const Gap(2),
                Text(
                  restaurant['avgPrice'] + '€',
                  style:
                      Styles.headLineStyle1.copyWith(color: Styles.textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
