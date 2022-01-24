import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;

class Shop extends StatefulWidget {
  Shop({Key? key}) : super(key: key);

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  var shopList = [];
  getData() async {
    try {
      var result = await firestore.collection('product').get();
      if (result.docs.isNotEmpty) {
        shopList = result.docs;
      }
    } catch (e) {
      print(e);
      print('에러남');
    }
  }

  login() async {
    try {
      var result = await auth.createUserWithEmailAndPassword(
        email: "park96h@naver.com",
        password: "gkdl",
      );
      result.user?.updateDisplayName('heemoon');
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    login();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shopList.length,
      itemBuilder: (c, i) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(shopList[i]['name']),
                Text(shopList[i]['price'].toString()),
              ],
            )
          ],
        );
      },
    );
  }
}
