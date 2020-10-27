import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:bennes/BenneWorkPage.dart';
import 'package:bennes/models/bennes.dart';
import 'package:bennes/terminaDia.dart';
import 'package:bennes/utils/SizeConfig.dart';
import 'package:bennes/utils/coordenadas.dart';
import 'package:bennes/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BenneCoursPage extends StatefulWidget {
  BenneCoursPage({
    Key key,
  }) : super(key: key);

  @override
  _BenneCoursPage createState() => _BenneCoursPage();
}

class _BenneCoursPage extends State<BenneCoursPage> {
  TextEditingController placas = TextEditingController();
  TextEditingController user = TextEditingController();
  String utilisateur;
  Timer timer;
  List<Bennes> bennes;
  List<String> benne = [];
  var res;
  bool condicao;
  bool existe;
  String latitude;
  String longitude;
  double accuracy;

  @override
  initState() {
    super.initState();
    getuser();
    existe=false;
    condicao = true;
    getBennes();
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
    timer = Timer.periodic(new Duration(seconds: 5), (timer) {
      setState(() {
        getBennes();
          if (this.accuracy < 20.0){
            posicaoCoordenadas(this.latitude, this.longitude, this.utilisateur);
       }
      });
    });
  }

  void getuser() async {
    this.utilisateur = await Preferences.getString('user');
  }

  void getBennes() {
    fetchBennes().then((value) => setState(() {
          this.bennes = value;
          this.benne.clear();
          for (int i = 0; i < this.bennes.length; i++) {
            if (this.bennes[i].chauffeur == this.utilisateur &&
                (this.bennes[i].status_ == '1' ||
                    this.bennes[i].status_ == '3')) {
              var st;
              setState(() {
                existe = true;
              });
              if (this.bennes[i].status_ == '1') {
                st = 'LIVRAISON';
              } else if (this.bennes[i].status_ == '3') {
                st = 'COLLECTE';
              }
              this.benne.add(this.bennes[i].number_ + '/' + st);
            }
          }
          setState(() {
            condicao = false;
          });
        }));
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
                terminarDia(context, this.utilisateur);
              },
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        persistentFooterButtons: <Widget>[
          Text('Accueil',
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
                    MaterialPageRoute(builder: (context) => BenneWorkPage()),
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
                    visible: existe == false  && condicao==false,
                    child: SizedBox(height: SizeConfig.safeBlockVertical * 30),
                  ),
                  Visibility(
                    visible: existe == false  && condicao==false,
                    child: Text('Aucunne Benne en cours',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockVertical * 3,
                        )),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: SizedBox(
                      height: SizeConfig.safeBlockVertical * 6,
                    ),
                  ),
                  Visibility(
                    visible: condicao == false,
                    child: Column(
                      children: this.benne.map((value) {
                        var resultado = value;
                        this.res = resultado.split('/');

                        return Card(
                          color: Colors.white,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          borderOnForeground: true,
                          elevation: 0,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: ListTile(
                            leading: Icon(Icons.pending_actions,
                                color: Colors.black),
                            title: Text(
                              'BENNE - >' + this.res[0],
                              style:
                                  TextStyle(fontSize: 25, color: Colors.black),
                            ),
                            subtitle: Text(
                              this.res[1],
                              style: TextStyle(
                                  fontSize: 20, color: Colors.blueGrey),
                            ),
                            onTap: () {},
                          ),
                        );
                      }).toList(),
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
