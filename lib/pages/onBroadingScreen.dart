import 'package:flutter/material.dart';
import 'package:food_delivery_app/services/widget_support.dart';

class Onbroadingscreen extends StatelessWidget {
  const Onbroadingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Image.asset("assets/onbroadingScreen2.png",height: MediaQuery.of(context).size.height/2,),
            SizedBox(height: 30,),
            Text("Delicious Food,\n One Tap Away",style:AppWidget.HeadlineTextField() ,textAlign:TextAlign.center,),
                        SizedBox(height: 20,),
            Text("Choose your meal and place your order",style:AppWidget.SimpleTextField(),textAlign: TextAlign.center ,),
            SizedBox(height: 40,),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width/2,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A00),
                borderRadius: BorderRadius.circular(15)
              ),
              child: Center(child: Text("Get Started",style: AppWidget.HeadlineTextField(),)),
            ),
          ],
        ),
      ),
    );
  }
}