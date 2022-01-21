import 'package:flutter/material.dart';
import "./style.dart" as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:flutter/rendering.dart';

void main() {
  runApp(
    MaterialApp(theme: style.theme, home: const MyApp()),
  );
}

var a = TextStyle(color: Colors.blue);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;
  var userContent;
  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  updateData() {
    var myData = {
      "id": data.length,
      "image": userImage,
      "likes": 0,
      "date": 'January 21',
      "content": userContent,
      'liked': false,
      "user": 'BARKEY96',
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  addData(a) {
    setState(() {
      data.add(a);
    });
  }

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
    print(data);
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instargram'), actions: [
        IconButton(
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => Upload(
                          userImage: userImage,
                          setUserContent: setUserContent,
                          updateData: updateData)));
            },
            icon: Icon(Icons.add_box_outlined)),
      ]),
      body: [
        MainContent(data: data, addData: addData),
      ][tab],
      bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (i) {
            setState(() {
              tab = i;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '홈',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), label: '샵')
          ]),
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({Key? key, this.data, this.addData}) : super(key: key);
  final data, addData;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  var scroll = ScrollController();
  moreData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);

    if (widget.data[widget.data.length - 1]['id'] < result2['id']) {
      widget.addData(result2);
    }
  }

  moreData2() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more2.json'));
    var result2 = jsonDecode(result.body);
    if (widget.data[widget.data.length - 1]['id'] < result2['id']) {
      widget.addData(result2);
    }
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        moreData();
        moreData2();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: (c, i) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.data[i]['image'].runtimeType == String
                    ? Image.network(widget.data[i]['image'])
                    : Image.file(widget.data[i]['image']),
                Text('좋아요  ${widget.data[i]['likes']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.data[i]['user'] ?? 'null'),
                Text(widget.data[i]['date'] ?? 'null'),
                Text(widget.data[i]['content'] ?? 'null'),
              ],
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }
}

class Upload extends StatelessWidget {
  Upload({
    Key? key,
    this.userImage,
    this.setUserContent,
    this.updateData,
  }) : super(key: key);
  final userImage, setUserContent, updateData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  updateData();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.send))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            Text('이미지업로드화면'),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '글제목을 입력하세요.',
              ),
              onChanged: (text) {
                setUserContent(text);
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)),
          ],
        ));
  }
}
