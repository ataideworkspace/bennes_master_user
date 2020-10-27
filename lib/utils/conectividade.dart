import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ToastHelper {
  static toast(msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

class ToastAviso {
  static toast(msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}

conectividade() async{
var connectivityResult = await (Connectivity().checkConnectivity());
if (connectivityResult == ConnectivityResult.mobile) {
  // ToastHelper.toast('lieson - reseaux mobile');
} else if (connectivityResult == ConnectivityResult.wifi) {
//    ToastHelper.toast('lieson - wifi');
 } else{
  ToastHelper.toast("Problèmes d'Internet, vérifiez si vous avez une connexion établie !");
}
}

proximidade() async{

  ToastAviso.toast("... à la recherche des bonnes coordonnées GPS !");

}

