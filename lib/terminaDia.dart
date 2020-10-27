import 'package:bennes/login.dart';
import 'package:bennes/utils/geolocation.dart';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/preferences.dart';
import 'package:bennes/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

var alertStyleBottom = AlertStyle(
  animationType: AnimationType.fromBottom,
  animationDuration: Duration(milliseconds: 1000),
);

var alertStyleTop = AlertStyle(
  animationType: AnimationType.fromTop,
  animationDuration: Duration(milliseconds: 1000),
);

terminarDia(context, user) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.warning,
    title: "GESTION DE BENNES",
    desc: "Êtes-vous sûr de vouloir déconnecter ?",
    buttons: [
      DialogButton(
        child: Text(
          "Accepter",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          endDelivery(context, user);
        },
        color: Color.fromRGBO(51, 102, 153, 1),
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

endDelivery(context, user) async {
  var url =
      urlClient() + pasta() + "/aplicacao/delivery/endDelivery.php?user=" + user;
  var response = await http.get(url);
  String resposta = response.body.toString();
  if (response.statusCode == 200) {
    if (resposta == '0') {
         Navigator.pop(context);
      sucessoFechar(context);
      // erroFechar(context,"Pour une raison inconnu, la demande ne peut être effectué, contactez l'assistance !");
    } else if (resposta == '1') {
        Navigator.pop(context);
      sucessoFechar(context);
    } else {
      Navigator.pop(context);
       erroFechar(context,"Vous pouvez pas fermer l'aplication, car il y a des bennes en cours!");
    }
  } else {
    print(resposta);
  }
}

void sucessoFechar(context) {
  Alert(
    style: alertStyleTop,
    context: context,
    type: AlertType.success,
    title: "GESTION DE BENNES",
    desc: 'Operation effectué',
    buttons: [
      DialogButton(
        child: Text(
          "fermer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          gpsEnd();
          Preferences.setString('camion', '');
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        width: 120,
      )
    ],
  ).show();
}

void erroFechar(context,mensagem) {
  Alert(
    style: alertStyleBottom,
    context: context,
    type: AlertType.error,
    title: "GESTION DE BENNES",
    desc: mensagem,
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
