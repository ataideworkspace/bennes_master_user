import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:bennes/BenneWorkPage.dart';
import 'package:bennes/terminaDia.dart';
import 'package:bennes/utils/SizeConfig.dart';
import 'package:bennes/utils/dialogs.dart';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/preferences.dart';
import 'package:bennes/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class StartWorkPage extends StatefulWidget {
  StartWorkPage({
    Key key,
  }) : super(key: key);

  @override
  _StartWorkPage createState() => _StartWorkPage();
}

class _StartWorkPage extends State<StartWorkPage> {
  String utilisateur;
  bool condicao;
  @override
  initState() {
    super.initState();
   condicao=true;
    getuser();
  }

  void getuser() async {
    this.utilisateur = await Preferences.getString('user');
    aceitaEncomenda(this.utilisateur);
  }

  aceitaEncomenda(user) async {
   
    var url =
        urlClient() + pasta() + "/aplicacao/delivery/delivery.php?user=" + user;
    var response = await http.get(url);
    String resposta = response.body.toString();
    if (response.statusCode == 200) {
      if (resposta.trim() == '') {
         setState(() { 
          condicao=false;
        });
      } else {
        Preferences.setString('camion', resposta);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BenneWorkPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      return ('erro');
    }
  }

  Future scanQRCamion(context) async {
      setState(() { 
          condicao=true;
        });
 
    try {
      String scanResult = await BarcodeScanner.scan();
    
      if (scanResult.substring(0, 6) == 'camion') {
        novaEncomenda(this.utilisateur, scanResult.substring(6));
      } else {
         setState(() { 
          condicao=false;
        });
   
        avisoErro(context,
            "Vérifiez si le code QR est endommagé et si le code appartient à un camion!");
      }
    } on PlatformException catch (ex) {
      throw (ex);
    } on FormatException catch (ex) {
      throw (ex);
    }
  }

  novaEncomenda(user, plates) async {
    var url = urlClient() +
        pasta() +
        "/aplicacao/delivery/newdelivery.php?user=" +
        user +
        '&plates=' +
        plates;
    var response = await http.get(url);
    String resposta = response.body.toString();
    if (response.statusCode == 200) {
      if (resposta.trim() == '0') {
       setState(() { 
          condicao=false;
        });
        avisoErro(context,
            "Pour une raison non reconnue, il y a eu un échec dans l'enregistrement, vérifiez la connexion ou contactez la centrale!");
      } else {
   
        Preferences.setString('camion', plates);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BenneWorkPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      return ('erro');
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
                terminarDia(context,this.utilisateur);
              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
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
                    child:SizedBox(height: SizeConfig.safeBlockVertical * 30),
                   ),
                  Visibility(
                    visible: condicao == true,
                    child: SpinKitChasingDots(
                      size:100,
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
                  visible:condicao==false,
                   child:SizedBox(
                    height: SizeConfig.safeBlockVertical * 21,
                  ),
                  ),
                   Visibility(
                  visible:condicao==false,
                   child:Text('Cliquez pour scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.safeBlockVertical * 3,
                      )),
                   ),
                    Visibility(
                  visible:condicao==false,
                   child:FlatButton(
                    child: Icon(Icons.qr_code,
                        size: SizeConfig.blockSizeHorizontal * 60,
                        color: Colors.white),
                    onPressed: () {
                      scanQRCamion(context);
                    },
                  ),
                    ),
                     Visibility(
                  visible:condicao==false,
                   child:SizedBox(height: SizeConfig.safeBlockVertical * 2),
                     ),
                   Visibility(
                  visible:condicao==false,
                   child: Text('scann camion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.safeBlockVertical * 3,
                      )),
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
