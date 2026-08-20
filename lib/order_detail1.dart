import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'home.dart';
import 'dart:io';
import 'dart:async';
//import 'package:stop_public/take_picture_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import "package:async/async.dart";
import 'package:path/path.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Img;
import 'dart:math' as Math;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stop_complaint/order_detail1.dart';
import 'un_available.dart';
import 'Model/cancelled.dart';
import 'delivery.dart';
import 'order_detail1.dart';
import 'login.dart';

class OrderDetail1 extends StatefulWidget {
  //final Order_Model? model;
  //final Function? updateHome;
  //final String? cid,complaint,violation,image,district,phone,address,slocation,sname,datetime,city;

  const OrderDetail1({
    Key? key,
    //this.model,
    //this.updateHome,
    //this.cid,
    //this.complaint,this.violation,this.image,this.district,this.phone,this.address,this.slocation,this.sname,this.datetime,this.city
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail1> with TickerProviderStateMixin {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);
  final TextEditingController cusname=new TextEditingController();
  final TextEditingController cuscity=new TextEditingController();
  final TextEditingController cusphone=new TextEditingController();
  final TextEditingController cusaddress=new TextEditingController();
  List<String> images = [
    "img/logo1.png",
    "img/logo2.png",
    "img/logowho.png",
    "img/logo.png",
  ];
  String? _mySelection;
  String? _mySelection1;
  String? _mySelection2;
  File? uploadimage;
  File? imageFile;
  List data = [];
  List data1=[];
  double? newversion;
  static final String uploadEndPoint ='http://stoptobacco.in/Android/imgupload.php';
  Future<File>? cameimag;
  //Future<File> imageFile;
  String status = '';
  String? base64Image;
  File? tmpFile;
  String errMessage = 'Error Uploading Image';
  String? lat;
  String? lng;
  File? _image;
  var compressImg;
  bool visible = false ;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> attachment=[];
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "";
  late StreamSubscription<Position> positionStream;
  @override
  void initState() {

    checkGps();
    getdata();

    super.initState();

  }
  String? _path;

  Position? _currentPosition;

  int _selectedIndex = 0;

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }


  void _showCamera() async {

    XFile? choosedimage = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 100, maxWidth: 100);

    setState(() {
      // _path = file.path;
      //uploadimage = File(choosedimage!.path);
      attachment .add(choosedimage!.path);

    });

  }
  setStatus(String message) {
    setState(() {
      status = message;
    });
  }
  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile!.path.split('/').last;
    // addProduct(fileName);
    upload(fileName);
  }
  upload(String fileName) {

    http.post(Uri.parse("http://stoptobacco.in/Android/app/up1.php"), body: {
      "image": base64Image,
      "name": fileName,
      "complaint": cusname.text.toString(),
      "violation": _mySelection.toString(),
      "address": cusaddress.text.toString(),
      "city": cuscity.text.toString(),
      "phone": cusphone.text.toString(),
      "district": _mySelection2.toString(),
      "clocation": 'https://maps.google.com/?daddr='+lat!+", "+long!,

    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
     // Fluttertoast.showToast(msg: result.toString());

    }).catchError((error) {
      setStatus(error);
    });
  }

  Future getImageCamera() async{

    var imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    attachment.add(imageFile!.path);

    final tempDir =await getTemporaryDirectory();
    final path = tempDir.path;

    int rand= new Math.Random().nextInt(100000);

    //Img.Image image= Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image? image=Img.decodeImage(await imageFile.readAsBytes());//Img.Image smallerImg = Img.copyResize(image);
    Img.Image smallerImg = Img.copyResizeCropSquare(image!, size: 350);
    //Img.Image smallerImg = Img.copyResize(image, 500);

    var compressImg1= new File("$path/image_$rand.jpg")..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));
    //..writeAsBytesSync(Img.encodeJpg(smallerImg, quality: 85));


    setState(() {
      _image = compressImg1;
    });
  }
String? dt;
  String? cid;
getdata()async
{
  SharedPreferences pref=await SharedPreferences.getInstance();
  dt=pref.getString('Dname');
  cid=pref.getString('cid');


}


  Future<void> uploadImage() async {
    //show your own loading or progressing code here

    String uploadurl = "http://stoptobacco.in/Android/app/up1.php";

    try{
      List<int> imageBytes = uploadimage!.readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      //convert file image to Base64 encoding
      var response = await http.post(
          Uri.parse(uploadurl),
          body: {
            'image': baseimage,
          }
      );
      if(response.statusCode == 200){
        var jsondata = json.decode(response.body); //decode json data
        if(jsondata["error"]){ //check error sent from server
          print(jsondata["msg"]);
          //if error return from server, show message from server
        }else{
          print("Upload successful");
        }
      }else{
        print("Error during connection to server");


        //status code might be 404 = url not found
      }
    }catch(e){
      print("Error during converting to Base64");
      //there is error during converting file image to base64 encoding.
    }
  }
  chooseImage() {
    setState(() {
      // file = ImagePicker.pickImage(source: ImageSource.camera);
      // var file =await ImagePicker().pickImage(source: ImageSource.camera);
    });
    setStatus('');
  }


  Widget showImage() {
    return FutureBuilder<File>(
      future: cameimag,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data!.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }
  Future<http.Response?> callWebServiceForLofinUser(BuildContext context) async {
    String fmail='tech5@tgs.net.in';
    if(cusname.text=="" || cusaddress.text=="" || cusphone.text==""|| cuscity.text=="")
    {
      // Fluttertoast.showToast(msg: "please fille all data..");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("please fille all data..")));
    }

    else {
      final paramDic = {
        "sname": '${cusname.text.toString()}',
        "email": '${_mySelection2.toString()}',
        "phone": '${cusphone.text.toString()}',
        "city": '${cuscity.text.toString()}',
        "message": '${cusaddress.text.toString()}',
        "violation": '${_mySelection1.toString()}',
        "district":'${_mySelection.toString()}',
        "gps":'https://maps.google.com/?daddr='+lat!+","+lng!,
        "email1":'${fmail.toString()}'

      };

      final loginData = await http.post(Uri.parse("http://www.stoptobacco.in/Android/getmail11.php"), body: paramDic);

      //);

      return loginData;
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final Widget imagePath = Text(attachment.length>0 ? attachment[0]: '');
    var uri = 'https://www.youtube.com/embed/48GWPTYTNwo';
    var encoded = Uri.encodeFull(uri);
    assert(encoded == 'https://www.youtube.com/embed/48GWPTYTNwo');
    var decoded = Uri.decodeFull(encoded);
    final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
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

    final name = TextField(
      controller: cusname,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Penalty Amount",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
    );




    Future addProduct(File imageFile) async {
      setState(() {
        visible = true ;
      });


      var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();
      var uri = Uri.parse("https://stoptobacco.in/Android/action.php");
      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile("image", stream, length, filename: basename(imageFile.path));
      request.files.add(multipartFile);
      request.fields['amount'] = cusname.text.toString();
      request.fields['district'] =dt.toString();
      request.fields['cid'] =cid.toString();
      request.fields['location'] = 'https://maps.google.com/?daddr='+lat!.toString()+","+long!.toString();
      var respond = await request.send();
      var respond1 = await http.Response.fromStream(respond);

      /*  Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => register()),
      );*/

      //var respond = await http.Response.fromStream(streamedResponse);
      if (respond.statusCode == 200) {

        setState(() {
          // prefs.setString('Uphone', cusphone.text.toString());
          //prefs.setString("Uimage", datauser[0]["Eimage"]);
          /*  return const Center(
          child: const Text('Please wait for Response...'),
          // child:CircularProgressIndicator()
        );*/
        });
        print("Image Uploaded");
        setState(() {
          visible = false;
        });
        // Fluttertoast.showToast(msg: "Submitted Successfully . Thank you");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Submitted Successfully . Thank you"),
              duration: Duration(seconds: 2),
            )
        );

        Navigator.push(
          this.context,
          MaterialPageRoute(builder: (context) => OrderDetail1()),
        );
        ScaffoldMessenger.of(this.context).showSnackBar(
            new SnackBar(
              content: new Text("Submitted Successfully"),
              duration: Duration(seconds: 10),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {

                },
              ),
            )
        );

      } else {
        print("Upload Failed");
        ScaffoldMessenger.of(this.context).showSnackBar(
            new SnackBar(
              content: new Text("Failed"),
              duration: Duration(seconds: 10),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(builder: (context) => OrderDetail1()),
                  );

                },
              ),
            )
        );
        setState(() {
          visible = false;
        });
      }
    }






    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff4180C5),
      //color: Colors.blue,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        //onPressed:send,
        onPressed:()=>addProduct(_image!),
        child: Text("Submit",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor:const Color(0xFFFFFFFF) ,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Text('Action Enforcement',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),textAlign: TextAlign.start,


            ),
            Flexible(fit: FlexFit.tight, child: SizedBox()),


          ],

        ),

        /*leading: Builder(

          builder: (context) => IconButton(
            color: Colors.black,
            icon: new Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),

          ),


        ),*/
      ),
      drawer: buildDrawer(context),
      resizeToAvoidBottomInset: true,
      body:CustomScrollView(
        slivers: [
         /* SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 20.0,),
              height: 120.0,
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Image.asset(images[index]);
                },
              ),
            ),
          ),*/
          SliverToBoxAdapter(
            child: Container(
              height: 70.0,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child:Text('Action Enforcement',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26,color: Colors.black),textAlign: TextAlign.center,),
                  )
                ],
              ),
            ),

          ),




          SliverToBoxAdapter(
            child: Center(

              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: _image==null
                            ? new Text("No image selected!")
                            : new Image.file(_image!),
                      ),

                      /* TextField(
                    controller: name,
                    decoration:new InputDecoration(
                      hintText: "Title",
                    ),
                  ),*/

                      //Image.file(file),
                      //showImage(),
                      SizedBox(
                        height: 0.0,
                      ),
                      ElevatedButton(
                        child: Text("Click Photo", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom( backgroundColor: Colors.green),
                        onPressed: () {
                          //_showOptions(context);
                          getImageCamera();
                          //chooseImage();
                        },
                      ),
                      SizedBox(height: 25.0),
                      InputDecorator(
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
                            // hintText: "Saddress *",
                            border:
                            OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                        child: DropdownButtonHideUnderline(
                          child:DropdownButton(


                            // style: style,
                            /* decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Company name",
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),*/
                            items: <String>['Use of tobacco in Public places',
                              'Opening or running a hookah bar',
                              'Tobacco products advertisements',
                              'Tobacco product sale by/to minors',
                              'Tobacco product sale within 100m of Educational Institutions',
                              'Sale of tobacco products loose or in single sticks',
                              'Tobacco Product sale without certified health warning on pack.',
                              'Violation of FCTC 5.3 ',
                              'PECA Violation'].map((String value) {
                              return new DropdownMenuItem(
                                child: new Text(value),
                                value: value,
                              );
                            }).toList(),
                            onChanged: (newVal) {

                              setState(() {
                                _mySelection1 = newVal.toString();
                                //Fluttertoast.showToast(msg: _mySelection1.toString());
                              });
                            },

                            isExpanded: true,
                            hint: Text('Choose the type of COTPA/PECA Violation'),
                            value: _mySelection1,
                          ),),),
                      SizedBox(height: 25.0),
                      name,


                      SizedBox(height: 25.0),
                      loginButon,
                      SizedBox(
                        height: 15.5,
                      ),
                      Visibility(
                          visible: visible,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: CircularProgressIndicator()
                          )
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ),


        ],
      ),
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
              label: 'Open',
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
          // selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        )

    );
  }
  Widget? buildDrawer(BuildContext context) {
    return null;
    /*return Drawer(
      child: Column(
        children: <Widget>[

          Expanded(
              flex: 5,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  // buildSeparators("Registeration"),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                  Divider(),

                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('About Us'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => about()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.account_box),
                    title: Text('Register a Complaint'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => register()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                      leading: Icon(Icons.image),
                      title: Text('COTPA'),
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => cotpa()),
                        );
                      }
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('IEC / Signages'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => download()),
                      );
                    },
                  ),
                  Divider(),

                  ListTile(
                    leading: Icon(Icons.contacts),
                    title: Text('Contact Us'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => contact()),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.contacts),
                    title: Text('Inbox'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => inbox()),
                      );
                    },
                  ),
                  Divider(),

                ],
              ))
        ],
      ),

    );*/
  }
  Widget buildSeparators(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(left: 10)),
        Text(
          name,
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      ],
    );
  }

  Widget buildTile(String name, String path, String imgPath) {
    return ListTile(
      leading: Image.asset(
        imgPath,
        scale: 1.2,
      ),
      title: Text(name),
      onTap: () {
        /*if ( path != '/login' && path != '/signUp' )
          Navigator.pop(context);
        else
          Navigator.pushNamed(context, path);*/
      },
    );
  }

  Widget? buildSwiper() {
    List<String> imgs = [
      'assets/images/img1.jpg',
      'assets/images/img2.jpg',
      'assets/images/img3.jpg',
      'assets/images/img4.jpg',
      'assets/images/img5.jpg',

    ];


  }

  /*Widget buildImgCarousel() {
    return Container(
      height: 30.0,
      child: new Carousel(
        boxFit: BoxFit.cover,
        images: [
          Image.asset('assets/images/img1.jpg'),
          AssetImage('assets/images/img2.jpg'),
          AssetImage('assets/images/img3.jpg'),
          AssetImage('assets/images/img4.jpg'),
          AssetImage('assets/images/img5.jpg'),

        ],
        autoplay: true,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 1000),
        dotSize: 5.0,
        indicatorBgPadding: 2.0,
        // dotColor: Colors.blue,
      ),
    );
  }*/
  _launchURL() async {
    final url = Uri.parse('http://tgs.net.in/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }



}
