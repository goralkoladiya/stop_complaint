import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_complaint/Helper/Session.dart';
import 'package:stop_complaint/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Helper/app_btn.dart';
import 'Helper/color.dart';
import 'Helper/constant.dart';
import 'Helper/string.dart';
import 'Model/order_model.dart';
import 'login.dart';
import 'un_available.dart';
import 'Model/cancelled.dart';
import 'delivery.dart';
import 'order_detail1.dart';

class OrderDetail extends StatefulWidget {
  //final Order_Model? model;
  //final Function? updateHome;
  final String? cid,complaint,violation,image,district,phone,address,slocation,sname,datetime,city;

  const OrderDetail({
    Key? key,
    //this.model,
    //this.updateHome,
    this.cid,
    this.complaint,this.violation,this.image,this.district,this.phone,this.address,this.slocation,this.sname,this.datetime,this.city
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<String> statusList = [
    "Open Complaints",
    "Closed Complaints",
    "Pending Complaints"
  ];
  bool? _isCancleable, _isReturnable, _isLoading = true;
  bool _isProgress = false;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;
String? dropdownvalue;
  @override
  void initState() {
    super.initState();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(index==0)
      {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );

      }
      else if(index==2)
      {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Delivery(),
          ),
        );
      }
      else if(index==1)
      {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Awaiting(),
          ),
        );
      }
      else if(index==3)
      {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
        );
      }
    });
  }
  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    //Order_Model model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate, rDate;

    /*if (model.listStatus!.contains(PLACED)) {
      pDate = model.listDate![model.listStatus!.indexOf(PLACED)];

      if (pDate != null) {
        List d = pDate.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus!.indexOf(PROCESSED)];
      if (prDate != null) {
        List d = prDate.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus!.indexOf(SHIPED)];
      if (sDate != null) {
        List d = sDate.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERD)];
      if (dDate != null) {
        List d = dDate.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus!.indexOf(CANCLED)];
      if (cDate != null) {
        List d = cDate.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus!.indexOf(RETURNED)];
      if (rDate != null) {
        List d = rDate.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;
*/
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(ORDER_DETAIL, context),
      body: _isNetworkAvail
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  elevation: 0,
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: [ Text(
                                                "Complaint#: ",
                                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                  //color: lightBlack2),
                                                    color: lightBlack,fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                '${widget.cid.toString()}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        //color: lightBlack2),
                                                        color: lightBlack),
                                              ),
                                              ]),
                                             /* Text(
                                                "${widget.busname}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                    color: lightBlack),
                                              ),*/
                                              InkWell(
                                                child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 15.0, vertical: 5),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.call,
                                                          size: 15,
                                                          color: fontColor,
                                                        ),
                                                        Text(" ${widget.phone.toString()}",
                                                            style: const TextStyle(
                                                                color: Colors.black,
                                                                decoration: TextDecoration.none)),
                                                      ],
                                                    )),
                                                onTap: _launchCaller,
                                              ),
                                            ],
                                          ),
                                         Image.network("https://stoptobacco.in/android/appimage/"+widget!.image.toString(), fit: BoxFit.contain,
                                           height: 450.0,
                                           width: 450.0,)
                                         /* Text(
                                            "Location: - ${widget.slocation.toString()}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(color: lightBlack),
                                          ),*/
                                        ],
                                      ))),
                             /* widget.area!= null && widget.area!.isNotEmpty
                                  ? Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          //"$PREFER_DATE_TIME: ${model.delDate!} - ${model.delTime!}",
                                          "$PREFER_DATE_TIME: ${widget.orderdate} - ${widget.timeslot}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(color: lightBlack2),
                                        ),
                                      ))
                                  : Container(),*/

                              shippingDetails(),
                              //priceDetails(),
                              /*ListView.builder(
                                shrinkWrap: true,
                                //itemCount: model.itemList!.length,
                                itemCount: 1,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {

                                  return Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  /*  ClipRRect(
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      child: FadeInImage(
                                                        fadeInDuration: const Duration(milliseconds: 150),
                                                        image: NetworkImage(orderItem.image!),
                                                        height: 90.0,
                                                        width: 90.0,
                                                        placeholder: placeHolder(90),
                                                      )),*/
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            widget.prdtname ?? '',
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .subtitle1!
                                                                .copyWith(
                                                                color: lightBlack,
                                                                fontWeight: FontWeight.normal),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          widget.prdtcode!.isNotEmpty
                                                              ? ListView.builder(
                                                              physics:
                                                              const NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              itemCount: 1,
                                                              itemBuilder: (context, index) {
                                                                return Row(children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      "Product code" + ":",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .subtitle2!
                                                                          .copyWith(color: lightBlack2),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets.only(left: 5.0),
                                                                    child: Text(
                                                                      widget.prdtcode!,//val[index],
                                                                      style: Theme.of(context)
                                                                          .textTheme
                                                                          .subtitle2!
                                                                          .copyWith(color: lightBlack),
                                                                    ),
                                                                  )
                                                                ]);
                                                              })
                                                              : Container(),
                                                          Row(children: [
                                                            Text(
                                                              "$QUANTITY_LBL:",
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .subtitle2!
                                                                  .copyWith(color: lightBlack2),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 5.0),
                                                              child: Text(
                                                                widget.quantity!,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(color: lightBlack),
                                                              ),
                                                            )
                                                          ]),
                                                          Text(
                                                            "Total Amt: ${CUR_CURRENCY!} ${num.parse(widget.grandtotal.toString())+50}",
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .subtitle1!
                                                                .copyWith(color: fontColor),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                vertical: 10.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(
                                                                        right: 8.0),
                                                                    child: DropdownButtonFormField(
                                                                      dropdownColor: lightWhite,
                                                                      isDense: true,
                                                                      iconEnabledColor: fontColor,
                                                                      //iconSize: 40,
                                                                      hint: Text(
                                                                        "Update Status",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .subtitle2!
                                                                            .copyWith(
                                                                            color: fontColor,
                                                                            fontWeight:
                                                                            FontWeight.bold),
                                                                      ),
                                                                      decoration: const InputDecoration(
                                                                        filled: true,
                                                                        isDense: true,
                                                                        fillColor: lightWhite,
                                                                        contentPadding:
                                                                        EdgeInsets.symmetric(
                                                                            vertical: 10,
                                                                            horizontal: 10),
                                                                        enabledBorder:
                                                                        OutlineInputBorder(
                                                                          borderSide: BorderSide(
                                                                              color: fontColor),
                                                                        ),
                                                                      ),
                                                                      // value: orderItem.status,
                                                                      onChanged: (dynamic newValue) {
                                                                        setState(() {
                                                                          dropdownvalue=newValue;
                                                                          //orderItem.curSelected =
                                                                          //  newValue;
                                                                        });
                                                                      },
                                                                      items:
                                                                      statusList.map((String st) {
                                                                        return DropdownMenuItem<String>(
                                                                          value: st,
                                                                          child: Text(
                                                                            capitalize(st),
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .subtitle2!
                                                                                .copyWith(
                                                                                color: fontColor,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .bold),
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                RawMaterialButton(
                                                                  constraints: const BoxConstraints.expand(
                                                                      width: 42, height: 42),
                                                                  onPressed: ()async {

                                                                    if (dropdownvalue.toString() == 'Update Status') {
                                                                      Fluttertoast
                                                                          .showToast(
                                                                          msg: "Please choose minium one Quantity");
                                                                    } else {
                                                                      final paramDic = {
                                                                      "status":dropdownvalue.toString(),
                                                                        "oid":widget.orderid,
                                                                        "uid":widget.uid,
                                                                        "sid":widget.sid,

                                                                      };

                                                                      final loginData = await http
                                                                          .post(
                                                                          Uri.parse(
                                                                              "https://meatbite.in/delivery/delivery_update.php"),
                                                                          body: paramDic);
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (
                                                                                context) =>
                                                                                Home()),
                                                                      );


Fluttertoast.showToast(msg: loginData.body.toString());
                                                                      // return loginData;
                                                                    }

                                                                  },
                                                                  elevation: 2.0,
                                                                  fillColor: fontColor,
                                                                  padding: const EdgeInsets.only(left: 5),
                                                                  child: const Align(
                                                                    alignment: Alignment.center,
                                                                    child: Icon(
                                                                      Icons.send,
                                                                      size: 20,
                                                                      color: white,
                                                                    ),
                                                                  ),
                                                                  shape: const CircleBorder(),
                                                                )
                                                              ],
                                                            ),
                                                          )

                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )));
                                },
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: DropdownButtonFormField(
                    //             dropdownColor: lightWhite,
                    //             isDense: true,
                    //             iconEnabledColor: fontColor,
                    //
                    //             hint: new Text(
                    //               "Update Status",
                    //               style: Theme.of(this.context)
                    //                   .textTheme
                    //                   .subtitle2!
                    //                   .copyWith(
                    //                       color: fontColor,
                    //                       fontWeight: FontWeight.bold),
                    //             ),
                    //            decoration: InputDecoration(
                    //               filled: true,
                    //               isDense: true,
                    //               fillColor: lightWhite,
                    //               contentPadding: EdgeInsets.symmetric(
                    //                   vertical: 10, horizontal: 10),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(color: fontColor),
                    //               ),
                    //             ),
                    //             value: widget.model!.activeStatus,
                    //             onChanged: (dynamic newValue) {
                    //               setState(() {
                    //                 curStatus = newValue;
                    //               });
                    //             },
                    //             items: statusList.map((String st) {
                    //               return DropdownMenuItem<String>(
                    //                 value: st,
                    //                 child: Text(
                    //                   capitalize(st),
                    //                   style: Theme.of(this.context)
                    //                       .textTheme
                    //                       .subtitle2!
                    //                       .copyWith(
                    //                           color: fontColor,
                    //                           fontWeight: FontWeight.bold),
                    //                 ),
                    //               );
                    //             }).toList(),
                    //           ),
                    //         ),
                    //       ),
                    //       RawMaterialButton(
                    //         constraints:
                    //             BoxConstraints.expand(width: 42, height: 42),
                    //         onPressed: () {
                    //           if (model.otp != null &&
                    //               model.otp!.isNotEmpty &&
                    //               model.otp != "0" &&
                    //               curStatus == DELIVERD)
                    //             otpDialog(
                    //                 curStatus, model.otp, model.id, false, 0);
                    //           else
                    //             updateOrder(curStatus, updateOrderApi, model.id,
                    //                 false, 0);
                    //         },
                    //         elevation: 2.0,
                    //         fillColor: fontColor,
                    //         padding: EdgeInsets.only(left: 5),
                    //         child: Align(
                    //           alignment: Alignment.center,
                    //           child: Icon(
                    //             Icons.send,
                    //             size: 20,
                    //             color: white,
                    //           ),
                    //         ),
                    //         shape: CircleBorder(),
                    //       )
                    //     ],
                    //   ),
                    // )
                  ],
                ),
                showCircularProgress(_isProgress, primary),
              ],
            )
          : noInternet(context),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0XFF025975),
          //backgroundColor: Colors.blue,
          //selectedItemColor: Colors.black,
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,size:30,color: Colors.white),

              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart_rounded,size:30,color: Colors.white),
              label: 'Open Complaint',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available,size:30,color: Colors.white,),
              label: 'Closed Complaint',
            ),

            /*BottomNavigationBarItem(
            icon: Icon(Icons.search,size:30,color: Color(0XFF009CCF),),
            title: Text('Serarch',style: TextStyle(color: Colors.black,fontSize: 20,),textAlign:TextAlign.center,),
          ),*/
            BottomNavigationBarItem(

              icon: Icon(Icons.logout,size:30,color: Colors.white,),
              label: 'Logout',),

          ],
          currentIndex: _selectedIndex,
          // selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        )
    );
  }


  _launchMap() async {
    String? url = '';

    if (Platform.isAndroid) {
      url =widget.slocation.toString();
          //"https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url = widget.slocation.toString();
          //"http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }

    if (await canLaunch(url!)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget priceDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 0.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            /*  Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text("Order Details : ",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: fontColor, fontWeight: FontWeight.bold))),*/
             /* const Divider(
                color: lightBlack,
              ),*/
                 /* Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child:Container(
                      color: Colors.green,
                      padding: const EdgeInsets.only(top:5,bottom: 5),
                      margin: const EdgeInsets.all(.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          //Text("Order No.${model.id!}"),
                          Text("  #"),
                          // const Spacer(),
                          Text("  Items"),
                          //const Spacer(),
                          //Text(orderList![index]['Usequence'].toString()),
                          const Spacer(),
                          Text("Qty"),
                          const Spacer(),
                          Text("Item No   "),
                        ],
                      ),
                    ),
                  ),*/
                               /*Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          //Text('${index+1}'+" "),

                                          Expanded(
                                            child: Text(
                                              widget!.violation.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const Spacer(),

                                    Flexible(
                                      child: Row(
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.only(left:10,right:0),
                                            child: Text(
                                              widget.complaint.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    InkWell(
                                      child: Row(
                                        children: [
                                          /* const Icon(
                                                                              Icons.call,
                                                                              size: 14,
                                                                              color: fontColor,
                                                                            ),*/
                                          Text(
                                            //json![index]['Status'],
                                            "24683",
                                            style: const TextStyle(
                                                color: Colors.black,
                                                decoration: TextDecoration.none),
                                          ),
                                        ],
                                      ),

                                    ),
                                  ],
                                ),
                              ),*/




                   Padding(
                padding: const EdgeInsets.only(left: 15.0,top:15, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /*Text("$PRICE_LBL :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("${CUR_CURRENCY!} ${widget.grandtotal}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("${CUR_CURRENCY!} ${widget.grandtotal}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),*/
                    const Spacer(),

                  ],
                ),
              ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0),
                            child: DropdownButtonFormField(
                              dropdownColor: lightWhite,
                              isDense: true,
                              iconEnabledColor: fontColor,
                              //iconSize: 40,
                              hint: Text(
                                "Update Status",
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                    color: fontColor,
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                isDense: true,
                                fillColor: lightWhite,
                                contentPadding:
                                EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10),
                                enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: fontColor),
                                ),
                              ),
                              // value: orderItem.status,
                              onChanged: (dynamic newValue) {
                                setState(() {
                                  dropdownvalue=newValue;
                                  //orderItem.curSelected =
                                  //  newValue;
                                });
                              },
                              items:
                              statusList.map((String st) {
                                return DropdownMenuItem<String>(
                                  value: st,
                                  child: Text(
                                    capitalize(st),
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                        color: fontColor,
                                        fontWeight:
                                        FontWeight
                                            .bold),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        RawMaterialButton(
                          constraints: const BoxConstraints.expand(
                              width: 42, height: 42),
                          onPressed: ()async {

                            /*if (dropdownvalue.toString() == 'Update Status') {
                              Fluttertoast
                                  .showToast(
                                  msg: "Please choose minium one Quantity");
                            } else {
                              final paramDic = {
                                "status":dropdownvalue.toString(),
                                "oid":widget.orderid,
                                "uid":widget.uid,
                                "sid":widget.orderid,

                              };

                              final loginData = await http
                                  .post(
                                  Uri.parse(
                                      "https://meatbite.in/delivery/delivery_update.php"),
                                  body: paramDic);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (
                                        context) =>
                                        Home()),
                              );


                              Fluttertoast.showToast(msg: loginData.body.toString());
                              // return loginData;
                            }*/

                          },
                          elevation: 2.0,
                          fillColor: fontColor,
                          padding: const EdgeInsets.only(left: 5),
                          child: const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.send,
                              size: 20,
                              color: white,
                            ),
                          ),
                          shape: const CircleBorder(),
                        )
                      ],
                    ),
                  )
            /*  Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$DELIVERY_CHARGE :",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2)),
                    Text("+ ${CUR_CURRENCY!} ${50}",
                        style: Theme.of(context)
                            .textTheme
                            .button!
                            .copyWith(color: lightBlack2))
                  ],
                ),
              ),



          Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$TOTAL_PRICE :",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold)),
                    Text("${CUR_CURRENCY!} ${num.parse(widget.grandtotal.toString())+50}",
                        style: Theme.of(context).textTheme.button!.copyWith(
                            color: lightBlack, fontWeight: FontWeight.bold))
                  ],
                ),
              ),*/
            ])));
  }

  Widget shippingDetails() {
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Row(
                    children: [
                      Text("Complaint Details",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        height: 30,
                        child: IconButton(
                            icon: const Icon(
                              Icons.location_on,
                              color: fontColor,
                            ),
                            onPressed: () {
                              _launchMap();
                            }),
                      )
                    ],
                  )),
              const Divider(
                color: lightBlack,
              ),
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      children: [
                  Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 1.0),child:Text(
                        "Name: ",
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                          //color: lightBlack2),
                            color: lightBlack,fontWeight: FontWeight.bold),
                      )),
                        Text(
                          '${widget.sname.toString()}',
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 15.0, right: 1.0),child:Text(
                          "Violation: ",
                          style: Theme.of(context)
                              .textTheme.titleMedium!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack,fontWeight: FontWeight.bold),
                        )),
                        Text(
                          '${widget.violation.toString()}',
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack),
                        ),
                      ]),

                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 14.0, right: 1.0),child:Text(
                          "Address: ",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack,fontWeight: FontWeight.bold),
                        )),
                        Expanded(
                          child: Text(
                            '${widget.address.toString()}',
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              //color: lightBlack2),
                                color: lightBlack),
                            softWrap: true,
                          ),
                        ),

                      ]),
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 15.0, right: 1.0),child:Text(
                          "City: ",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack,fontWeight: FontWeight.bold),
                        )),
                        Text(
                          '${widget.city.toString()}',
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 15.0, right: 1.0),child:Text(
                          "Date & Timings: ",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            //color: lightBlack2),
                              color: lightBlack,fontWeight: FontWeight.bold),
                        )),
                        Text(
                        //" ${capitalize(widget.city.toString()!)}"+" - "+" ${capitalize(widget.datetime.toString()!)}",
                        " ${capitalize(widget.datetime.toString()!)}",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                            //color: lightBlack2),
                              color: lightBlack),
                        ),
                      ]),

        Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 1.0),child: AppBtn(
    title: 'Action Enforment',
    btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
      SharedPreferences pref=await SharedPreferences.getInstance();
      pref.setString("district", widget.district.toString());
      pref.setString("cid", widget.cid.toString());
      /*Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderDetail1(

              )));*/



      if(widget.cid.toString()==null)
      {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }else{
        //ids=prefs.getString('Uid');

      }
      final paramDic = {


        /*"balanceamount":'${num.parse(_balanceamount.text)}',
      "advanceamount":'${num.parse(_advanceamount.text)}',
      "comment":'${_comments.text}',*/

        "cid":widget.cid.toString(),
      };

      final loginData = await http.post(Uri.parse("https://stoptobacco.in/android/officer/update-complaint.php"),body: paramDic);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('uid', ids.toString());
//Fluttertoast.showToast(msg: loginData.body.toString());
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetail1()));


          //validateAndSubmit();
    },
    )),

             /* Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
                  child: Text(capitalize(widget!.saddress!+", "+widget.pincode!),
                      style: const TextStyle(color: lightBlack2))),
              InkWell(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.call,
                          size: 15,
                          color: fontColor,
                        ),
                        Text(" ${widget.phone}",
                            style: const TextStyle(
                                color: fontColor,
                                decoration: TextDecoration.underline)),
                      ],
                    )),
                onTap: _launchCaller,
              ),*/
            ])));
  }

  Widget productItem(OrderItem orderItem, Order_Model model, int i) {
    List att = [], val = [];
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }
    String dropdownvalue = 'Item 1';
    return Card(
        elevation: 0,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: NetworkImage(orderItem.image!),
                          height: 90.0,
                          width: 90.0,
                          placeholder: placeHolder(90),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderItem.name ?? '',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                      color: lightBlack,
                                      fontWeight: FontWeight.normal),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            orderItem.attr_name!.isNotEmpty
                                ? ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: att.length,
                                    itemBuilder: (context, index) {
                                      return Row(children: [
                                        Flexible(
                                          child: Text(
                                            att[index].trim() + ":",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightBlack2),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            val[index],
                                            style: Theme.of(context).textTheme.titleSmall!
                                                .copyWith(color: lightBlack),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),
                            Row(children: [
                              Text(
                                "$QUANTITY_LBL:",
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(color: lightBlack2),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  orderItem.qty!,
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: lightBlack),
                                ),
                              )
                            ]),
                            Text(
                              "${CUR_CURRENCY!} ${orderItem.price!}",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(color: fontColor),
                            ),
                            1 >= 1
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: DropdownButtonFormField(
                                              dropdownColor: lightWhite,
                                              isDense: true,
                                              iconEnabledColor: fontColor,
                                              //iconSize: 40,
                                              hint: Text(
                                                "Update Status",
                                                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                        color: fontColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              decoration: const InputDecoration(
                                                filled: true,
                                                isDense: true,
                                                fillColor: lightWhite,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 10),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: fontColor),
                                                ),
                                              ),
                                              value: orderItem.status,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  orderItem.curSelected =
                                                      newValue;
                                                  dropdownvalue=newValue;
                                                });
                                              },
                                              items:
                                                  statusList.map((String st) {
                                                return DropdownMenuItem<String>(
                                                  value: st,
                                                  child: Text(
                                                    capitalize(st),
                                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                                            color: fontColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                );
                                              }).toList(),

                                            ),
                                          ),
                                        ),
                                        RawMaterialButton(
                                          constraints: const BoxConstraints.expand(
                                              width: 42, height: 42),
                                          onPressed: () {
                                            //Fluttertoast.showToast(msg: "hi test");
                                           // Fluttertoast.showToast(msg: dropdownvalue.toString());

                                          },
                                          elevation: 2.0,
                                          fillColor: fontColor,
                                          padding: const EdgeInsets.only(left: 5),
                                          child: const Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.send,
                                              size: 20,
                                              color: white,
                                            ),
                                          ),
                                          shape: const CircleBorder(),
                                        )
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  Future<void> updateOrder(
      String? status,  String? id, bool item, int index,String? otp) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          _isProgress = true;
        });

        var parameter = {ORDERID: id, STATUS: status, DEL_BOY_ID: CUR_USERID,OTP:otp};
        if (item) parameter[ORDERITEMID] = widget.cid;

        print(parameter.toString());
        Response response = await post(updateOrderItemApi,
                body: parameter,
                headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        setSnackbar(msg);
        if (!error) {
          if (item) {
           // widget.model!.itemList![index].status = status;
          } else {
            //widget.model!.activeStatus = status;
          }
        }

        setState(() {
          _isProgress = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  _launchCaller() async {
    var url = "tel:${widget.phone}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }
}
