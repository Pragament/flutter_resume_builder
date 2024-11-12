import 'package:flutter/material.dart';

class JobContainer extends StatelessWidget {
  final String  title, location, description, minSalary,maxSalary;
  final Function() onTap;

  const JobContainer(
      {super.key,
      required this.title,
      required this.location,
      required this.description,
      required this.minSalary,
        required this.maxSalary,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5.0,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "$title",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "$location",
                        style: Theme.of(context).textTheme.titleSmall?.apply(
                              color: Colors.grey,
                            ),
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Text(
              "$description",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 9),
           Row(
             children: [
               Text(
                 "₹$minSalary/month",
                 style: Theme.of(context)
                     .textTheme
                     .titleMedium
                     ?.apply(fontWeightDelta: 2),
               ),
               SizedBox(width: 20,
               child: Text(" to ",style: TextStyle(fontWeight: FontWeight.bold,),),
               ),
               Text(
                 "₹$maxSalary/month",
                 style: Theme.of(context)
                     .textTheme
                     .titleMedium
                     ?.apply(fontWeightDelta: 2),
               )
             ],
           )
          ],
        ),
      ),
    );
  }
}
