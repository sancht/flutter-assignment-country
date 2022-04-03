import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'src/country_details.dart';
import 'src/country_template.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Countries'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  static const String url = 'https://countries.trevorblades.com/graphql';

  bool _loading = false;

  late List cachedCountriesList = [];

  Map colorResults = {};
  String lastSearchText = '';
  String lastFilterText = '';

  late Widget _appBarTitle;

  final TextEditingController _controller = TextEditingController();

  final ValueNotifier<String> _filter = ValueNotifier<String>('');

  @override
  initState(){
    super.initState();
    _appBarTitle = Text(widget.title);
  }

  requestData(){
    setState(() {
      _loading = true;
    });
    http.get(Uri.parse(
        '$url?query={country(code: "${lastSearchText.toUpperCase()}") {name native capital emoji currency languages {code name}}}')).then((http
        .Response res) {
          print((jsonDecode(res.body)));
      if (res.statusCode == 200) {
        if((jsonDecode(res.body))['data']['country'] != null) {
          colorResults[lastSearchText] = (jsonDecode(res.body));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No Country Found!'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              )
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.body),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            )
        );
      }
      setState(() {
        _loading = false;
      });
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong..'),
            duration: Duration(seconds: 2),
          )
      );
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _appBarTitle is TextField ? Colors.white :null,
        title: _appBarTitle,
        actions: [
          _appBarTitle is Text ? IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              setState(() {
                _appBarTitle = TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: 'Enter country Code',
                      hintStyle: TextStyle(
                          color: Colors.grey
                      )
                  ),
                  controller: _controller,
                  onEditingComplete: (){
                    if(!_loading) {
                      lastSearchText = _controller.text.trim();
                      if (!colorResults.containsKey(lastSearchText)) {
                        requestData();
                      } else {
                        setState(() {});
                      }
                    }
                  },
                );
              });
            },
          ) : IconButton(
            icon: const Icon(Icons.close, color: Colors.black87,),
            onPressed: (){
              setState(() {
                _controller.text = '';
                lastSearchText = '';
                _appBarTitle = Text(widget.title);
              });
            },
          )
        ],
      ),
      body: _appBarTitle is Text ? FutureBuilder<List>(
        future: () async {
          if(cachedCountriesList.isEmpty) {
            setState(() {
              _loading = true;
            });
            http.Response res = await http.get(Uri.parse(
                '$url?query={countries {name code states {name} languages {name}}}'));
            print(res.body);
            _loading = false;
            cachedCountriesList = (jsonDecode(res.body)['data']['countries'] as List);
            cachedCountriesList.sort((a, b)=>a['name'].toString().compareTo(b['name']));
          }
          return cachedCountriesList;
        }(),
        builder: (_, __){
          return _loading || !__.hasData ? const Center(child: CircularProgressIndicator()) : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                            hintText: 'Filter by Name/Language/States',
                            hintStyle: TextStyle(
                                color: Colors.grey
                            )
                        ),
                        onChanged: (_){
                          _filter.value = _;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: _filter,
                  builder: (context, value, child) {
                    Widget ret = ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[...__.data!.where((element) => filterFn(element, value.trim())).map((e) =>
                          InkWell(
                            child: ListTile(
                                title: Text('${e['name']}')
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) {
                                    return Country(e);
                                  }));
                            },
                          )).toList()
                      ],
                    );
                    return ret;
                  },
                ),
              ),
            ],
          );
        },
      ) : Card(
        child: colorResults[lastSearchText] == null || colorResults[lastSearchText]['data'] == null ? const Center(
          child: Text('Enter Code!'),
        ) : CountryTemplate(colorResults[lastSearchText]['data']['country']),
      ),
    );
  }

  bool filterFn(element, String trim) => element['name'].toString().toUpperCase().contains(trim.toUpperCase()) || ['states', 'languages'].any((el) => element[el].any((x)=>x['name'].toUpperCase().contains(trim.toUpperCase()) as bool) as bool);
}