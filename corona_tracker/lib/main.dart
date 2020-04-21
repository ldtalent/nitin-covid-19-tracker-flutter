import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'graph.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/graph': (context) => GraphPage(), 
      },
      title: 'Corona Tracker',
    );
  }
}

typedef void func();


var jsonResponse;

class CallAPI{

  static String url = 'https://api.thevirustracker.com/free-api?countryTimeline=US';

  static void getData(func f) async{
    var response = await http.get(url);
    if (response.statusCode == 200) {
      jsonResponse = convert.jsonDecode(response.body);
      print("API SUCCESS!");
      f();
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class DataPoint{
  String date;
  int num;
  DataPoint(this.date, this.num);
}

class _MyHomePageState extends State<MyHomePage> {

  List<DataPoint> timeline = List<DataPoint>();
  
    void loadData(){
      setState(() {
        jsonResponse = jsonResponse['timelineitems'][0];
       // print(jsonResponse);

        jsonResponse.forEach((key, val){
          if(key != 'stat'){
            //print(key);
            //print(val['total_cases']);
            timeline.add(DataPoint(key, val['total_cases']));
          }
        });
        
        print(timeline.length);
        print("\n\n");
        //print(timeline);
      });
    } 


    @override
  void initState() {
    super.initState();
    CallAPI.getData(loadData);
  }

  @override
  Widget build(BuildContext context) {

    if(jsonResponse == null){
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'CoronaVirus Tracker',
            ),
          ),
          backgroundColor: Colors.purple,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                child: Icon(Icons.show_chart, color: Colors.white,),
                onTap: (){},
                splashColor: Colors.red,
              ),
            ),
          ],
        ),
        body: Center(child: Text('Loading Data...'),),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'CoronaVirus Tracker',
            ),
          ),
          backgroundColor: Colors.purple,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                child: Icon(Icons.show_chart, color: Colors.white,),
                onTap: (){
                  Navigator.pushNamed(context, '/graph', arguments: timeline);
                },
                splashColor: Colors.red,
              ),
            ),
          ],
        ),
        body: ShowListView(timeline),
      );
    }
  }
}

class ShowListView extends StatelessWidget {
  final List<DataPoint> timeline;

  ShowListView(this.timeline);

  @override
  Widget build(BuildContext context) {
    print(timeline.length);
    print("\n\n");
    return ListView.builder(
      itemCount: timeline.length,
      itemBuilder: (context, index){
        return Column(
            children: <Widget>[
              ListTile(
              leading: Text("${timeline[index].date}"),
              title:  Center(child: Text("Total Cases: ${timeline[index].num}")),
            ),
            Divider(),
        ]
        );
      }
    );
  }
}