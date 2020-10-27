import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:bennes/BenneCoursPage.dart';
import 'package:bennes/terminaDia.dart';
import 'package:bennes/utils/SizeConfig.dart';
import 'package:bennes/utils/coordenadas.dart';
import 'package:bennes/utils/dialogs.dart';
import 'package:bennes/utils/geolocation.dart';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/preferences.dart';
import 'package:bennes/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BenneWorkPage extends StatefulWidget {
  BenneWorkPage({
    Key key,
  }) : super(key: key);

  @override
  _BenneWorkPage createState() => _BenneWorkPage();
}

class _BenneWorkPage extends State<BenneWorkPage> {
  TextEditingController camion = TextEditingController();
  TextEditingController user = TextEditingController();
  bool condicao;
  String latitude, longitude;
  double accuracy;
  Timer timer;


  @override
  initState() {
    super.initState();
    condicao = false;
    getDados();
    gpsStart();
    gpsGetPosition();
    relogio();
  }

gpsGetPosition() {
 BackgroundLocation.getLocationUpdates((location) {
this.latitude=location.latitude.toString();
this.longitude=location.longitude.toString();
this.accuracy=location.accuracy;
});
}
  void relogio() {
    timer = Timer.periodic(new Duration(seconds: 10), (timer) {
      setState(() {
       if (this.accuracy < 20.0){
        posicaoCoordenadas(this.latitude, this.longitude, user.text);
       }
      });
    });
  }

  void getDados() async {
    camion.text = await Preferences.getString('camion');
    user.text = await Preferences.getString('user');
  }

  scanBenne(context, numero) async {
    setState(() {
      condicao = true;
    });
    var url = urlClient() +
        pasta() +
        "/aplicacao/benne/scanbenne.php?numero=" +
        numero;
    var response = await http.get(url);
    String resposta = response.body.toString();
    if (response.statusCode == 200) {
      if (resposta.trim() == '') {
        setState(() {
          condicao = false;
        });
        avisoErro(context,
            "Numero de benne invalide. Vérifiez la connection, ou contactez la central!");
      } else {
        caseResposta(context, resposta.trim(), numero, user.text);
           setState(() {
          condicao = false;
        });
      }
    } else {
      return ('erro');
    }
  }

  void caseResposta(context, resposta, numero, user) {
    switch (resposta) {
      case '0':
        {
          livrerBenne(context, numero, user);
        }
        break;
      case '1':
        {
          chantierBenne(context, numero, user);
        }
        break;
      case '2':
        {
          collecterBenne(context, numero, user);
        }
        break;
      case '3':
        {
          stockerBenne(context, numero, user);
        }
        break;
    }
  }

  Future scanQRbenne(context) async {
  
    try {
      String scanResult = await BarcodeScanner.scan();

      if (scanResult.substring(0, 5) == 'benne') {
        scanBenne(context, scanResult.substring(5));
      } else {
        avisoErro(context,
            "Vérifiez si le code QR est endommagé et si le code appartient à une benne!");
      }
    } on PlatformException catch (ex) {
      throw (ex);
    } on FormatException catch (ex) {
      throw (ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(51, 102, 153, 0.1),
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                height: 50,
              ),
            ],
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.settings_power),
              onPressed: () {
                timer.cancel();
                terminarDia(context,user.text);
              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        persistentFooterButtons: <Widget>[
          Text('Bennes en cours',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockVertical * 3,
              )),
          IconButton(
            icon: Icon(Icons.arrow_forward_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                timer.cancel();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => BenneCoursPage()),
                    (Route<dynamic> route) => false);
              });
            },
          ),
        ],
        backgroundColor: Color.fromRGBO(51, 102, 153, 0.6),
        body: SingleChildScrollView(
          child: Container(
            width: SizeConfig.safeBlockHorizontal * 100,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Center(
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: condicao == true,
                    child: SizedBox(height: SizeConfig.safeBlockVertical * 30),
                  ),
                  Visibility(
                    visible: condicao == true,
                    child: SpinKitChasingDots(
                      size: 100,
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.blueGrey.shade300
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: SizedBox(
                      height: SizeConfig.safeBlockVertical * 12,
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: Container(
                      margin: EdgeInsets.only(left: 60, right: 60),
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 30,
                        ),
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5.0),
                          disabledBorder: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        readOnly: false,
                        controller: user,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: SizedBox(
                      height: SizeConfig.safeBlockVertical * 4,
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: Text('Cliquez pour scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockVertical * 3,
                        )),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: FlatButton(
                      child: Icon(Icons.qr_code,
                          size: SizeConfig.blockSizeHorizontal * 60,
                          color: Colors.white),
                      onPressed: () {
                        scanQRbenne(context);
                      },
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: Text('scann benne',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockVertical * 3,
                        )),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: Container(
                      margin: EdgeInsets.only(left: 60, right: 60),
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5.0),
                          disabledBorder: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        readOnly: true,
                        controller: camion,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
