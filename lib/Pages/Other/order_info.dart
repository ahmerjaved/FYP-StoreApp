import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/Components/custom_button.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';
import 'package:vendor/baseurl/baseurlg.dart';
import 'package:vendor/beanmodel/orderbean/todayorderbean.dart';

class OrderInfo extends StatefulWidget {
  final TodayOrderMain mainP;

  OrderInfo(this.mainP);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  TodayOrderMain productDetails;
  var http = Client();
  bool isLoading = false;
  dynamic apCurrency;

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  void getSharedPrefs() async {
    productDetails = widget.mainP;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });
  }

  @override
  void dispose() {
    try {
      http.close();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(!('${productDetails.orderStatus}'.toUpperCase() == 'PENDING'));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    '${locale.orderinfo} - (#${productDetails.cartId})',
                    style: TextStyle(fontSize: 15),
                  ),
                  actions: [
                    Visibility(
                      visible: ('${productDetails.orderStatus}'.toUpperCase() == 'PENDING'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: MaterialButton(
                          onPressed: () {
                            if (!isLoading) {
                              setState(() {
                                isLoading = true;
                              });
                              cancelOrder(context);
                            }
                          },
                          color: kMainColor,
                          height: 45,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          child: Text(
                            locale.cancelOrdr,
                            style: TextStyle(color: kWhiteColor, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.all(5),
                                child: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network('${productDetails.orderDetails[index].varientImage}', fit: BoxFit.cover)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${productDetails.orderDetails[index].productName} (${productDetails.orderDetails[index].quantity} ${productDetails.orderDetails[index].unit})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: kWhiteColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '${locale.invoice2h} - ${productDetails.orderDetails[index].qty}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kWhiteColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${locale.invoice3h} - $apCurrency ${double.parse((productDetails.orderDetails[index].price / productDetails.orderDetails[index].qty).toStringAsFixed(2))}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kWhiteColor,
                                        ),
                                      ),
                                      Text(
                                        '${locale.invoice4h} ${locale.invoice3h} - $apCurrency ${productDetails.orderDetails[index].price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kWhiteColor,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, indext) {
                      return Divider(
                        thickness: 0.1,
                        color: Colors.transparent,
                      );
                    },
                    itemCount: productDetails.orderDetails.length),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            Text(locale.orderedOn + ' ${productDetails.orderDetails[0].orderDate}', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 13)),
                            Spacer(),
                            Text(locale.orderID + ' #${productDetails.cartId}', style: Theme.of(context).textTheme.subtitle2),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(locale.deliveryDate + ' ${productDetails.deliveryDate} ${productDetails.timeSlot} ', style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 13)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${productDetails.orderStatus}',
                            style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '${productDetails.paymentMode} (${productDetails.paymentStatus})',
                            style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: '${locale.order1} ${locale.invoice3h}. ',
                              style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: '$apCurrency ${productDetails.orderPrice.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).backgroundColor, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Spacer(),
                          RichText(
                            text: TextSpan(
                              text: '${locale.qnt}. ',
                              style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(text: '${productDetails.orderDetails.length} items', style: TextStyle(color: Theme.of(context).backgroundColor, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: (productDetails.deliveryBoyName != null),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        thickness: 8,
                        color: Colors.grey[100],
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(locale.deliveryperson, style: Theme.of(context).textTheme.subtitle2),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${productDetails.deliveryBoyName}\n',
                                    style: Theme.of(context).textTheme.subtitle1,
                                    children: <TextSpan>[
                                      TextSpan(text: '${productDetails.deliveryBoyPhone}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(Icons.call),
                                    color: kMainColor,
                                    onPressed: () {
                                      _launchURL("tel:${productDetails.deliveryBoyPhone}");
                                    })
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 8,
                  color: Colors.grey[100],
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(locale.shippingAddress, style: Theme.of(context).textTheme.subtitle2),
                          IconButton(
                              icon: Icon(Icons.call),
                              color: kMainColor,
                              onPressed: () {
                                _launchURL("tel:${productDetails.userPhone}");
                              })
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      RichText(
                        text: TextSpan(
                          text: '${productDetails.userName}\n\n',
                          style: Theme.of(context).textTheme.subtitle1,
                          children: <TextSpan>[
                            TextSpan(text: '${productDetails.userAddress}\n\n', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15)),
                            TextSpan(text: '${productDetails.userPhone}', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: (!(productDetails.deliveryBoyName != null)),
                  child: (isLoading)
                      ? Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Align(
                            widthFactor: 40,
                            heightFactor: 40,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : CustomButton(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            assignOrderetoBoy();
                          },
                          height: 60,
                          iconGap: 12,
                          label: locale.assignboy,
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void assignOrderetoBoy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    http.post(assignBoyToOrderUri, body: {
      'store_id': '${prefs.getInt('store_id')}',
      'cartId': '${productDetails.cartId}',
      // 'dboy_id':'$deliveryboyid',
    }).then((value) {
      print(value.body);
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        setState(() {
          productDetails.orderStatus = 'Confirmed';
        });
        Navigator.of(context).pop();
      } else {
        showAlertDialog(context);
      }
      Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void cancelOrder(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    http.post(cancelOrderUri, body: {
      'store_id': '${prefs.getInt('store_id')}',
      'cartId': '${productDetails.cartId}',
    }).then((value) {
      print(value.body);
      setState(() {
        productDetails.orderStatus = 'Cancelled';
        isLoading = false;
      });
      Navigator.of(context).pop(true);
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  showAlertDialog(BuildContext context) async {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Ok',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text('Notice'),
            content: Text('No Driver is online now.'),
            actions: [clear],
          );
        });
      },
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
