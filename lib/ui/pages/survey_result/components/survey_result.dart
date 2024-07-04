import 'package:flutter/material.dart';

class SurveyResult extends StatelessWidget {
  const SurveyResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.only(
              top: 40,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: const Text('Qual é seu framework web favorito?'),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withAlpha(90),
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.network(
                    // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcR5U16C8yXgBpl7-Bc7Itjx3_LRl425zINA&s', // React
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3qAb3e9auwnxJ1RmaypTdsieWkl2wb4u3cg&s', // Angular
                    width: 40,
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Angular',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1)
          ],
        );
      },
    );
  }
}
