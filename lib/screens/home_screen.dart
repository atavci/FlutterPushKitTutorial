import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_push_kit_tutorial/model/coupon.dart';
import 'package:huawei_push/push.dart';
import 'package:huawei_push/constants/channel.dart' as Channel;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNotificationsActive = true;
  bool _subscribed = false;

  String _token = '';
  static const EventChannel TokenEventChannel =
      EventChannel(Channel.TOKEN_CHANNEL);

  static const EventChannel DataMessageEventChannel =
      EventChannel(Channel.DATA_MESSAGE_CHANNEL);

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getToken();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    TokenEventChannel.receiveBroadcastStream()
        .listen(_onTokenEvent, onError: _onTokenError);
    DataMessageEventChannel.receiveBroadcastStream()
        .listen(_onDataMessageEvent, onError: _onDataMessageError);
  }

  void _onTokenEvent(Object event) {
    // This function gets called when we receive the token successfully
    setState(() {
      _token = event;
    });
    print('Push Token: ' + _token);
    Push.showToast(event);
  }

  void _onTokenError(Object error) {
    setState(() {
      _token = error;
    });
    Push.showToast(error);
  }

  void getToken() async {
    await Push.getToken();
  }

  void _onDataMessageEvent(Object event) {
    Map<String, dynamic> dataObj = json.decode(event);
    if (dataObj['type'] == 'coupon') {
      Coupon coupon = Coupon.fromJson(dataObj);
      showCouponDialog(coupon);
    } else {
      print('Unsupported Data Message Type');
    }
    Push.showToast(event);
  }

  void _onDataMessageError(Object error) {
    Push.showToast(error);
  }

  void turnOnPush() async {
    dynamic result = await Push.turnOnPush();
    Push.showToast(result);
  }

  void turnOffPush() async {
    dynamic result = await Push.turnOffPush();
    Push.showToast(result);
  }

  void subscribeToCoupons() async {
    setState(() {
      _subscribed = true;
    });
    dynamic result = await Push.subscribe('coupon');
    Push.showToast(result);
  }

  showCouponDialog(Coupon coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
            child: Text(
          coupon.title.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.green,
            fontSize: 25,
          ),
        )),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        content: Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(coupon.body),
              SizedBox(
                height: 10,
              ),
              Text(
                coupon.couponCode,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              MaterialButton(
                color: Colors.green,
                child: Text(
                  'Claim Now',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HMS Push Kit Example'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                isNotificationsActive = !isNotificationsActive;
                if (isNotificationsActive) {
                  turnOnPush();
                } else {
                  turnOffPush();
                }
              });
              Scaffold.of(context).showSnackBar(buildSnackbar(
                  isNotificationsActive
                      ? 'Notifications Enabled'
                      : 'Notifications Disabled'));
            },
            icon: isNotificationsActive
                ? Icon(Icons.notifications_active)
                : Icon(Icons.notifications_off),
          )
        ],
        centerTitle: true,
      ),
      body: Builder(
          // An inner BuildContext so that the onPressed methods
          // can refer to the Scaffold with Scaffold.of().
          builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Subscribe to coupon topic to get free coupons'),
              SizedBox(
                height: 20,
              ),
              OutlineButton(
                onPressed: _subscribed ? null : () => subscribeToCoupons(),
                child: Text('Subscribe Now'),
                borderSide: BorderSide(color: Colors.green),
                textColor: Colors.green,
              ),
            ],
          ),
        );
      }),
    );
  }

  buildSnackbar(String text) => SnackBar(content: Text(text));
}
