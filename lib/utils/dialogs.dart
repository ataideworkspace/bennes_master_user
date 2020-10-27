import 'dart:async';
import 'package:bennes/utils/conectividade.dart';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

 var alertStyleTop = AlertStyle(
      animationType: AnimationType.fromTop,
      animationDuration: Duration(milliseconds: 1000),
  );

   var alertStyleBottom = AlertStyle(
      animationType: AnimationType.fromBottom,
      animationDuration: Duration(milliseconds: 1000),
  );

updateBenne( context, latitude, longitude, numero, user) async {
 
  var url = urlClient() +
      pasta() + "/aplicacao/ caminho a darnumero=?" + numero + '&user=' + user + '&latitude=' + latitude + '&longitude=' + longitude;
  var response = await http.get(url);
  String resposta = response.body.toString();
  if (response.statusCode == 200) {
  //sucesso
  } else {
    print(resposta);
  }
}

void updateEncomenda(context,valor,numero, user) async{
 Location location = new Location();
  StreamSubscription<LocationData> locationSubscription;
  locationSubscription =
      location.onLocationChanged.listen((LocationData currentLocation) {
    if (currentLocation.accuracy > 20) {
      proximidade();
    } else {
      posicaoBenne(context, currentLocation.latitude,
          currentLocation.longitude, numero, user, valor);
      locationSubscription.cancel();
    }
  });
}

posicaoBenne( context, latitude, longitude, numero, user, valor) async {
  var url = urlClient() +
      pasta() + "/aplicacao/benne/updateBenne.php?numero=" + numero + '&user=' + user + '&latitude=' + latitude.toString() + '&longitude=' + longitude.toString() + '&valor=' + valor;
  var response = await http.get(url);
  if (response.statusCode == 200) {
    sucesso(context,'Operation correctement effectué',numero);
  } else {
   avisoErro(context,'Erreur : ' + response.statusCode.toString());
  }
}



void sucesso(context, resposta, numeroEncomenda) {
  Alert(
    style: alertStyleTop,
    context: context,
    type: AlertType.success,
    title: "GESTION DE BENNES",
    desc: resposta,
    buttons: [
      DialogButton(
        child: Text(
          "fermer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
           Navigator.pop(context);
           
        },
        width: 120,
      )
    ],
  ).show();
}


void avisoErro(context,motivo) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.error,
    title: "GESTION DE BENNES",
    desc: motivo,
    buttons: [
      DialogButton(
        child: Text(
          "fermer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        width: 120,
      )
    ],
  ).show();
}

  void livrerBenne(context,numero, user) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.warning,
    title: 'LIVRAISON',
    desc: "Voulez vous faire le livraison de la benne " + numero + ' ?',
    buttons: [
      DialogButton(
        child: Text(
          "Accépter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
      Navigator.pop(context);
      posicaoBenne( context, '', '', numero, user, '1');
        },
        color: Color.fromRGBO(121, 166, 210, 1),
      ),
       DialogButton(
           child: Text(
            "Annuler",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
           Navigator.pop(context);
          },
          color: Color.fromRGBO(153, 0, 0, 0.8),
        )
    ],
  ).show();
}


void chantierBenne(context,numero, user) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.warning,
    title: 'DÉPOSER BENNE',
    desc: "Voulez vous deposer la benne " + numero + ' sur le chantier?',
    buttons: [
      DialogButton(
        child: Text(
          "Accépter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
      Navigator.pop(context);
      updateEncomenda(context,'2',numero, user);
        },
        color: Color.fromRGBO(121, 166, 210, 1),
      ),
       DialogButton(
           child: Text(
            "Annuler",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
           Navigator.pop(context);
          },
          color: Color.fromRGBO(153, 0, 0, 0.8),
        )
    ],
  ).show();
}

void collecterBenne(context,numero, user) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.warning,
    title: 'COLLECTION',
    desc: "Voulez vous collecter la benne " + numero + ' ?',
    buttons: [
      DialogButton(
        child: Text(
          "Accépter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
         Navigator.pop(context);
         posicaoBenne( context, '', '', numero, user, '3');
        },
        color: Color.fromRGBO(121, 166, 210, 1),
      ),
       DialogButton(
           child: Text(
            "Annuler",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Color.fromRGBO(153, 0, 0, 0.8),
        )
    ],
  ).show();
}


void stockerBenne(context,numero, user) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.warning,
    title: 'STOCK BENNE',
    desc: "Voulez stocker la benne " + numero + ' ?',
    buttons: [
      DialogButton(
        child: Text(
          "Accépter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
      Navigator.pop(context);
       posicaoBenne( context, '', '', numero, user, '0');
        },
        color: Color.fromRGBO(121, 166, 210, 1),
      ),
       DialogButton(
           child: Text(
            "Annuler",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
           Navigator.pop(context);
          },
          color: Color.fromRGBO(153, 0, 0, 0.8),
        )
    ],
  ).show();
}

