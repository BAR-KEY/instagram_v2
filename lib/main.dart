import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "./style.dart" as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'shop.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (c) => Store1(),
    ),
    ChangeNotifierProvider(
      create: (c) => Store2(),
    )
  ], child: MaterialApp(theme: style.theme, home: MyApp())));
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
    savaData();
  }

  savaData() async {
    for (int i = 0; i < data.length; i++) {
      var storage = await SharedPreferences.getInstance();

      // var myData = {
      //   "id": data[i]['id'],
      //   "image": data[i]["image"],
      //   "likes": data[i]["likes"],
      //   "date": data[i]["data"],
      //   "content": data[i]["content"],
      //   'liked': data[i]["liked"],
      //   "user": data[i]["user"],
      // };
      var myData = {
        "id": data[i]['id'],
        "image": data[i]["image"],
        "likes": data[i]["likes"],
        "date": data[i]["data"],
        "content": data[i]["content"],
        'liked': data[i]["liked"],
        "user": data[i]["user"],
      };

      storage.setString('myData', jsonEncode(myData));
      var result = storage.getString('myData') ?? 'null';
      print(jsonDecode(result));
      // print(jsonDecode(result)['age']);
    }
  }

  @override
  void initState() {
    super.initState();

    getData();
    initNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('알림'),
        onPressed: () {
          showNotification2();
        },
      ),
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
            icon: Icon(Icons.add_box_outlined))
      ]),
      body: [MainContent(data: data, addData: addData), Shop()][tab],
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
                GestureDetector(
                  child: Text(widget.data[i]['user'] ?? 'null'),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => Profile(),
                        ));
                  },
                ),
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

class Store1 extends ChangeNotifier {
  var follower = 0;
  var followBool = false;
  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(profileImage[0]);
    notifyListeners();
  }

  var profileImage = [];

  followCount() {
    if (followBool == false) {
      follower++;
      followBool = true;
    } else {
      follower--;
      followBool = false;
    }
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier {
  var name = 'BARKEY';
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    context.read<Store1>().getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.watch<Store2>().name),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(),
            ),
            SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (c, i) => SizedBox(
                    child: Image.network(
                      '${context.read<Store1>().profileImage[i]}',
                    ),
                  ),
                  childCount: context.read<Store1>().profileImage.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3))
          ],
        ));
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey,
      ),
      Text('팔로우 ${(10 + context.watch<Store1>().follower).toString()}명'),
      ElevatedButton(
          onPressed: () {
            context.read<Store1>().followCount();
          },
          child: Text('팔로우')),
    ]);
  }
}
