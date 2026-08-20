import 'dart:async';
import 'dart:convert';

import 'package:stop_complaint/Helper/Session.dart';
import 'package:stop_complaint/Helper/cropped_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/app_btn.dart';
import 'Helper/color.dart';
import 'Helper/constant.dart';
import 'Helper/string.dart';
import 'home.dart';
import 'privacy_policy.dart';
import 'send_otp.dart';
// import 'package:fluttertoast/fluttertoast.dart' as prefix0;
import 'package:stop_complaint/splash.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? password, mobile, username, email, id, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.8,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        setState(() {
          _isNetworkAvail = false;
        });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: fontColor),
      ),
      backgroundColor: lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight),
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

  Future getLoginUser() async {
      final response = await http.post(Uri.parse("https://stoptobacco.in/android/district_login.php"), body: {
        "email": emailController.text,
        "password": passwordController.text,
      });

      var datauser = json.decode(response.body.toString());

      /* Fluttertoast.showToast(
        msg: datauser[0].toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );*/

      //prefix0.Fluttertoast.showToast(msg: datauser.toString());
      if(datauser[0].toString()=="Login Failed" || passwordController.text.isEmpty || emailController.text.isEmpty)
      {

        // _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text("Login failed or please fill correct username and password")));
        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
                content: new Text('Incorrect username / password')

            )
        );

      }
      else if(datauser[0]["Dusername"].toString()==emailController.text && datauser[0]["Dpassword"].toString()==passwordController.text)
      {
        SharedPreferences? prefs = await SharedPreferences.getInstance();
        String? username,email,mobile,id;
        setState(() {
         prefs.setString('Did', datauser[0]["Did"]);
         prefs.setString('Dname',datauser[0]["Dname"]);
          prefs.setString('Dusername',datauser[0]["Dusername"]);
          prefs.setString('Dpassword', datauser[0]["Dpassword"]);


          //prefs.setString("Uimage", datauser[0]["Eimage"]);
        });
        saveUserDetail(datauser[0]['Did'],datauser[0]['Dname'], datauser[0]['Dusername'], datauser[0]['Dpassword']);
        setPrefrenceBool(isLogin, true);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Splash(),
            ));

       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => backimag()),
        );*/
        /*ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: new Text('Login Successful'),
            duration: Duration(seconds: 10),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => backimag()),
                );

              },
            ),
          )
      );*/

      }

      else
      {


        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
                content: new Text('Incorrect username / password')
            )
        );
      }


      //  print(datauser);

  }

  Widget signInTxt() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 30.0,left: 30
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            SIGNIN_LBL,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: primary, fontWeight: FontWeight.bold,),
          ),
        ));
  }

  Widget termAndPolicyTxt() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(CONTINUE_AGREE_LBL,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: fontColor, fontWeight: FontWeight.normal)),
          const SizedBox(
            height: 3.0,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicy(
                                title: TERM,
                              )));
                },
                child: Text(
                  TERMS_SERVICE_LBL,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: fontColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
            const SizedBox(
              width: 5.0,
            ),
            Text(AND_LBL,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: fontColor, fontWeight: FontWeight.normal)),
            const SizedBox(
              width: 5.0,
            ),
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(
                                title: PRIVACY,
                              )));
                },
                child: Text(
                  PRIVACY_POLICY_LBL,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: fontColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.normal),
                )),
          ]),
        ],
      ),
    );
  }

  Widget setMobileNo() {
    return Container(
      width: deviceWidth! * 0.8,
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(

        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
       // inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(10),],
        //validator: validate,
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.email,
            color: Colors.black,
            size: 17,
          ),
          hintText: 'District Username (E-mail)',
          hintStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 20),
          // filled: true,
          // fillColor: lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: fontColor),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  Widget setPass() {
    return Container(
        width: deviceWidth! * 0.8,
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: true,
          focusNode: passFocus,
          style: TextStyle(color: fontColor),
          controller: passwordController,
          validator: validatePass,
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Colors.black,
              size: 17,
            ),
            hintText: PASSHINT_LBL,
            hintStyle: Theme.of(this.context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.black, fontWeight: FontWeight.normal,fontSize: 20),
            // filled: true,
            // fillColor: lightWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightBlack2),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  Widget forgetPass() {
    return Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                // setPrefrence(ID, id!);
                // setPrefrence(MOBILE, mobile!);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendOtp(
                              title: FORGOT_PASS_TITLE,
                            )));
              },
              child: Text(FORGOT_PASSWORD_LBL,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.normal,fontSize: 20)),
            ),
          ],
        ));
  }

  Widget loginBtn() {
    return AppBtn(
      title: SIGNIN_LBL,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Container(
          color:lightWhite,

          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: back(),
              ),
              Image.asset(
                'assets/images/doodle.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
              getLoginContainer(),
              getLogo(),
            ],
          ),
        )
            : noInternet(context));
  }

  Widget getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height *2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      signInTxt(),
                      setMobileNo(),
                      setPass(),
                      forgetPass(),
                      loginBtn(),
                     // termAndPolicyTxt(),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        //child: SvgPicture.asset(
        child: Image.asset(
          //'assets/images/loginlogo.svg',
          'assets/images/splashlogo.png',
        ),
      ),
    );
  }
}
