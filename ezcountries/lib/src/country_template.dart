
import 'package:flutter/material.dart';

class CountryTemplate extends StatelessWidget {
  final Map data;

  const CountryTemplate(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${data['name']}', style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),),
            Text('${data['emoji']}',
              style: const TextStyle(
                  fontSize: 24
              ),),
          ],
        ),
        if(data['name'] != data['native']) Text('(${data['native']})',
          style: const TextStyle(
              color: Colors.grey
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text('Capital: ${data['capital'] ?? '-'}'),
        Text('Currency: ${data['currency'] ?? '-'}'),
        Text('Languages: ${(data['languages']).map((item){
          return item['name'];
        }).toList().join(', ')}')
      ],
    );
  }
}