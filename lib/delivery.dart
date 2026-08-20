import 'dart:async';
import 'dart:convert';

import 'package:flutter_dash/flutter_dash.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:stop_complaint/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Helper/app_btn.dart';
import 'Helper/color.dart';
import 'Helper/constant.dart';

import 'Helper/string.dart';
import 'Model/cancelled.dart';
import 'login.dart';
import 'Model/order_model.dart';
import 'notification_lIst.dart';
import 'order_detail.dart';
import 'privacy_policy.dart';
import 'wallet_history.dart';
import 'delivery.dart';
// import 'cancelled.dart';
import 'un_available.dart';
import 'package:stop_complaint/home.dart';
class Delivery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateDelivery();
  }
}

int? total, offset;
//List<Order_Model> orderList = [];
List? orderList;
bool _isLoading = true;
bool isLoadingmore = true;
bool isLoadingItems = true;

class StateDelivery extends State<Delivery> with TickerProviderStateMixin {
  int curDrwSel = 0;

  bool _isNetworkAvail = true;
  List<Order_Model> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? profile;
  ScrollController controller = ScrollController();
  List<String> statusList = [
    "Open Complaints",
    "Close Complaints",
    "Pending Complaints"
  ];
  String? activeStatus;
String address="";
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
  void initState() {
    offset = 0;
    total = 0;
    //orderList.clear();
    getSetting();
    getOrder();
    getUserDetail();
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
    controller.addListener(_scrollListener);

    super.initState();
    getData2();
  }
  Future<String> getPosts1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ids=prefs!.getString('Did');
    var jsonResponse = await http.get(Uri.parse("https://meatbite.in/delivery/delivertotal.php?ids="+ids.toString()));
    return jsonResponse.body;
  }
String oid="";
  List? data;
  String? quantity;
  getData2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ids=prefs.getString('Did');
    if(ids==null)
    {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }else{
      ids=prefs.getString('Did');
    }

    var response = await http.get(
        Uri.parse("https://meatbite.in/delivery/deliveryorder.php?ids="+ids.toString()),
        headers: {
          "Accept": "application/json"
        }
    );
    this.setState((){
    quantity=prefs.getString('Dname');
    address=prefs.getString('Dusername')!;
      // prefix0.Fluttertoast.showToast(msg: quantity.toString());

    });
    //newversion=double.parse(data1[0]['vcode'].toString());
    // prefix0.Fluttertoast.showToast(msg: data[0]['total']);

    // print(data[0]['total']);

    return "Success!";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: AppBar(
        title: Text(
          appName,
          style: TextStyle(
            color: grad2Color,
          ),
        ),
        iconTheme: IconThemeData(color: grad2Color),
        backgroundColor: white,
        actions: [
          InkWell(
              onTap: filterDialog,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: primary,
                  )))
        ],
      ),
      drawer: _getDrawer(),
      body: _isNetworkAvail
          ? _isLoading
          ? shimmer()
          : /*RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: */SingleChildScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailHeader(),

                    orderList!.isEmpty
                        ? isLoadingItems
                        ? const Center(
                        child: CircularProgressIndicator())
                        : const Center(child: Text(noItem))
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: (offset! < total!)
                          ? orderList!.length + 1
                          : orderList!.length,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {

                        oid=orderList![index]['Cid'];
                        return (index == orderList!.length &&
                            isLoadingmore)
                            ? const Center(
                            child:
                            CircularProgressIndicator())
                        //: orderItem(index);
                            : Card(
                          elevation: 0,
                          margin: const EdgeInsets.all(5.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                                    Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text("Complaint#: ",style: TextStyle(fontWeight: FontWeight.bold),),

                                        Text(orderList![index]['Cid'].toString()),
                                        const Spacer(),
                                        InkWell(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.call,
                                                size: 14,
                                                color: Colors.black,
                                              ),
                                              Text(
                                                " "+orderList![index]['Rphone'],
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    decoration: TextDecoration.none),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            _launchCaller(index);
                                          },
                                        ),



                                        const Spacer(),
                                        IconButton(
                                            icon: const Icon(
                                              Icons.location_on,
                                              color: fontColor,
                                            ),
                                            onPressed: () {
                                              _launchCaller1(index);
                                            }),

                                      ],
                                    ),
                                  ),

                                  Divider(),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              // Text('${index+1}'+" "),

                                              Expanded(
                                                child: Text(
                                                  "Violation: "+orderList![index]['Cviolation'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // const Spacer(),


                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                    child: Row(
                                      children: [

                                        // const Spacer(),

                                        Flexible(
                                          child: Row(
                                            children: [

                                              Padding(
                                                padding: const EdgeInsets.only(left:10,right:0),
                                                child: Text(
                                                  "City: "+orderList![index]['Ccity'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        InkWell(
                                          onTap: () async {

                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => OrderDetail(cid:orderList![index]['Cid'],complaint:orderList![index]['Ccomplaint'],
                                                    violation:orderList![index]['Cviolation'],image:orderList![index]['Cimage'],

                                                    district:orderList![index]['Cdistrict'],

                                                    //orderdate:json1![index]['Orderdate'],
                                                    phone:orderList![index]['Rphone'],address:orderList![index]['Caddress'],city:orderList![index]['Ccity'],
                                                    sname:orderList![index]['Rname'],slocation:orderList![index]['Clocation'],datetime:orderList![index]['Cdatetime'],




                                                  )),
                                            );

                                            // getOrder();
                                          },
                                          child: Row(
                                            children: [
                                              /* const Icon(
                                                                              Icons.call,
                                                                              size: 14,
                                                                              color: fontColor,
                                                                            ),*/
                                              Text(
                                                //json![index]['Status'],
                                                "View Details",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    decoration: TextDecoration.none),
                                              ),
                                            ],
                                          ),

                                        ),
                                      ],
                                    ),
                                  ),


                                ])),

                          ),
                        );
                      },
                    )
                  ])))
          : noInternet(context),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0XFF025975),
          //backgroundColor: Colors.blue,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home,size:30,color: Colors.white),

              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart_rounded,size:30,color: Colors.white),
              label: 'Open',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available,size:30,color: Colors.white,),
              label: 'Closed',
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
          //selectedItemColor: Colors.red,
          onTap: _onItemTapped,
        )
    );
  }

  void filterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: const ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: AlertDialog(
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          'Filter By',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: fontColor),
                        )),
                    Divider(color: lightBlack),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getStatusList()),
                      ),
                    ),
                  ]),
                )),
          );
        });
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              children: [
                Container(
                  width: double.maxFinite,
                  child: TextButton(
                      child: Text(capitalize(statusList[index]),
                          style: Theme.of(context)
                              .textTheme.titleMedium!.copyWith(color: lightBlack)),
                      onPressed: () {
                        setState(() {
                          activeStatus = index == 0 ? null : statusList[index];
                          isLoadingmore = true;
                          offset = 0;
                          isLoadingItems = true;
                        });


                        if(statusList[index].toString()=='Delivered')
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Delivery(),
                              ));
                        }
                       else if(statusList[index].toString()=='Rejected')
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cancelled(),
                              ));
                        }
                        //getOrder();

                        else if(statusList[index].toString()=='Unavailable')
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Awaiting(),
                              ));
                        }
                        else
                        {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Home(),
                              ));
                        }

                      }),
                ),
                const Divider(
                  color: lightBlack,
                  height: 1,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder();
        });
      }
    }
  }

  Drawer _getDrawer() {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: white,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              _getHeader(),
              Divider(),
              _getDrawerItem(0, HOME_LBL, Icons.home_outlined),
              _getDrawerItem(7, WALLET, Icons.account_balance_wallet_outlined),
              // _getDrawerItem(5, NOTIFICATION, Icons.notifications_outlined),
              _getDivider(),
              _getDrawerItem(8, PRIVACY, Icons.lock_outline),
              _getDrawerItem(9, TERM, Icons.speaker_notes_outlined),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDivider(),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDrawerItem(11, LOGOUT, Icons.input),
            ],
          ),
        ),
      ),
    );
  }


  Widget _getHeader() {
    return InkWell(
      child: Container(
        decoration: back(),
        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CUR_USERNAME!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: white, fontWeight: FontWeight.bold),
                    ),
                    /*Text("$WALLET_BAL: ${CUR_CURRENCY!}$CUR_BALANCE"+"15",
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: white)),*/
                    Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                          ],
                        ))
                  ],
                )),
            Spacer(),
            Container(
              margin: const EdgeInsets.only(top: 20, right: 20),
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.0, color: white)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: imagePlaceHolder(62),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {


        setState(() {});
      },
    );
  }

  Widget _getDivider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        height: 1,
      ),
    );
  }

  Widget _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          gradient: curDrwSel == index
              ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                secondary.withOpacity(0.2),
                primary.withOpacity(0.2)
              ],
              stops: [
                0,
                1
              ])
              : null,
          // color: curDrwSel == index ? primary.withOpacity(0.2) : Colors.transparent,

          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          )),
      child: ListTile(
        dense: true,
        leading: Icon(
          icn,
          color: curDrwSel == index ? primary : lightBlack2,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: curDrwSel == index ? primary : lightBlack2, fontSize: 15),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (title == HOME_LBL) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
          } else if (title == NOTIFICATION) {
            setState(() {
              curDrwSel = index;
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(),
                ));
          } else if (title == LOGOUT) {
            logOutDailog();
          } else if (title == PRIVACY) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: PRIVACY,
                  ),
                ));
          } else if (title == TERM) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: TERM,
                  ),
                ));
          } else if (title == WALLET) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Delivery(),
                ));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _refresh() {
    offset = 0;
    total = 0;
    orderList!.clear();

    setState(() {
      _isLoading = true;
      isLoadingItems = false;
    });
    orderList!.clear();
    return getOrder();
  }

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                LOGOUTTXT,
                style: Theme.of(this.context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      LOGOUTNO,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: Text(
                      LOGOUTYES,
                      style: Theme.of(this.context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      clearUserSession();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Login()),
                          (Route<dynamic> route) => false);
                    })
              ],
            );
          });
        });
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
                  getOrder();
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

  Future<Null> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (offset == 0) {
        orderList = [];
      }
      try {
        CUR_USERID = await getPrefrence(ID);
        CUR_USERNAME = await getPrefrence(USERNAME);

        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString()
        };
        if (activeStatus != null) {
          if (activeStatus == awaitingPayment) activeStatus = "awaiting";
          parameter[ACTIVE_STATUS] = activeStatus;
        }
        SharedPreferences pref=await SharedPreferences.getInstance();

        Response response =await http.post(Uri.parse('https://stoptobacco.in/android/officer/closed_complaints.php?Cdistrict='+pref.getString('Dname').toString()),body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        orderList = json.decode(response.body.toString());

        //Fluttertoast.showToast(msg: CUR_USERID.toString()+getdata.toString());
        //bool error = getdata["error"];
        //String? msg = getdata["message"];
       // total = int.parse(getdata[0]["Grandtotal"]);
//Fluttertoast.showToast(msg: offset.toString()+total.toString());
       // if (!error) {


        if (mounted)
          setState(() {
            _isLoading = false;
            isLoadingItems = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
          isLoadingItems = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
          isLoadingItems = false;
        });
    }

    return null;
  }

  Future<Null> getUserDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID};

        Response response =
            await post(Uri.parse('https://meatbite.in/delivery/deliveryproduct.php?ID='+CUR_USERID.toString()), body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"][0];
          CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
          CUR_BONUS = data[BONUS];
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }

    return null;
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

  Widget orderItem(int index) {
    Order_Model model = orderList![index];
    Color back;

    /*if ((model.itemList![0].status!) == DELIVERD)
      back = Colors.green;
    else if ((model.itemList![0].status!) == SHIPED)
      back = Colors.orange;
    else if ((model.itemList![0].status!) == CANCLED ||
        model.itemList![0].status! == RETURNED)
      back = Colors.red;
    else if ((model.itemList![0].status!) == PROCESSED)
      back = Colors.indigo;
    else if (model.itemList![0].status! == WAITING)
      back = Colors.black;
    else
      back = Colors.cyan;*/

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //Text("Order No.${model.id!}"),
                    Text("Order No."+orderList![index]['OrderId'].toString()),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0))),
                      child: Text(
                        capitalize(orderList![index]['paymode']),
                        style: const TextStyle(color: white),
                      ),
                    )
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 14),
                          Expanded(
                            child: Text(
                              orderList![index]['Prdtname'] != null && orderList![index]['Prdtname'].isNotEmpty
                                  ? " ${orderList![index]['Prdtname']}"
                                  : " ",
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
                          const Icon(
                            Icons.call,
                            size: 14,
                            color: fontColor,
                          ),
                          Text(
                           orderList![index]['paymode'],
                            style: const TextStyle(
                                color: fontColor,
                                decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                      onTap: () {
                        _launchCaller(index);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.money, size: 14),
                        Text(" Payable: ${CUR_CURRENCY!} ${orderList![index]['Grandtotal']}"),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 14),
                        Text(" ${orderList![index]['Grandtotal']}"),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 14),
                    Text(" Order on: ${orderList![index]['Transaction_id']}"),
                  ],
                ),
              )
            ])),
        onTap: () async {
        /*  await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetail(model: orderList![index])),
          );*/
          setState(() {
            /* _isLoading = true;
             total=0;
             offset=0;
orderList.clear();*/
           // getUserDetail();
          });
          // getOrder();
        },
      ),
    );
  }

  _launchCaller(index) async {
    var url = "tel:${orderList![index]['Sphone']}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _launchCaller1(index) async {
    var url = "${orderList![index]['Slocation']}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  _detailHeader() {
    return Row(
      children: [
       /* Expanded(
          flex: 2,
          child: Card(
              elevation: 0,
              child:InkWell(
                  onTap: (){

                  },


                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        /*Container(
                      margin: EdgeInsets.only(top: 16),
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(width: 1.5, color: Colors.greenAccent)),
                    ),
                    Dash(
                        direction: Axis.horizontal,
                        length: 130,
                        dashLength: 15,
                        dashColor: Colors.grey),
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width: 2, color: red)),
                      child: Container(
                        height: 20,
                      ),
                    ),*/
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:<Widget>[  const Icon(
                              //Icons.shopping_cart,
                              Icons.location_on,
                              color: fontColor,
                            ),
                              Dash(
                                  direction: Axis.horizontal,
                                  length: 60,
                                  dashLength: 15,
                                  dashColor: fontColor),
                              const Icon(
                                //Icons.shopping_cart,
                                Icons.location_on,
                                color: fontColor,
                              )]),
                        // Text(ORDER),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(
                              color: fontColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ) )),
        ),*/
        Expanded(
            flex: 3,
            child: Card(
              elevation: 0,
              child:InkWell(
                onTap:(){
                  /*  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Delivery(),
                  ));*/
                },

                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_alert,
                        color: fontColor,
                      ),
                      Text( CUR_USERNAME!,),
                      /*FutureBuilder<String>(
                      future: getPosts1(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'There was an error :(',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline1,
                          );
                        } else if (snapshot.hasData) {
                          var data1 = json.decode(snapshot.data.toString());
                          int subtotal = int.parse(data1[0]['total'].toString());

return Text("");

                         /* return  Text(
                            "${CUR_CURRENCY!} $subtotal",
                            style: const TextStyle(
                                color: fontColor, fontWeight: FontWeight.bold),
                          );*/
                        } else {
                          return const Center(
                            //child: const Text('Loading...'),
                              //child: CircularProgressIndicator()
                          );
                        }
                      }),*/
                    ],
                  ),
                ),
              ),
            )),
        /* Expanded(
          flex: 2,
          child: Card(
    elevation: 0,
            child:InkWell(
    onTap: (){
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Awaiting(),
          ));
    },

            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.wallet_giftcard,
                    color: fontColor,
                  ),
                  const Text(BONUS_LBL),
                  Text(
                    CUR_BONUS!,
                    style: const TextStyle(
                        color: fontColor, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        )),*/
      ],
    );
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter = {TYPE: CURRENCY};

      Response response =
          await post(getSettingApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          CUR_CURRENCY = getdata["currency"];
        } else {
          setSnackbar(msg!);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }
}
