import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'country_template.dart';

class Country extends StatefulWidget {

  final Map data;

  const Country(this.data, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Country();
  }
}

class _Country extends State<Country> {

  static const String url = 'https://countries.trevorblades.com/graphql';

  requestData() async {
    Map ret = {};
    try {
      http.Response res = await http.get(Uri.parse(
          '$url?query={country(code: "${widget.data['code'].toUpperCase()}") {name native capital emoji currency languages {code name}}}'));
      if (res.statusCode == 200) {
        ret = (jsonDecode(res.body));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.body),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            )
        );
      }
      return ret;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong..'),
            duration: Duration(seconds: 2),
          )
      );
      return ret;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Details'),
      ),
      body: FutureBuilder(
          future: () async {
            var map = await requestData();
            return map;
          }(),
          builder: (_, __){
            return !__.hasData ? const Center(child: CircularProgressIndicator()) : Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CountryTemplate((__.data as Map)['data']['country']),
                )
            );
          }
      ),
    );
  }
}