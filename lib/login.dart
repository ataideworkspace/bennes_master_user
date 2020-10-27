import 'dart:convert';
import 'package:bennes/StartWorkPage.dart';
import 'package:bennes/utils/conectividade.dart';
import 'package:bennes/utils/SizeConfig.dart';
import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/preferences.dart';
import 'package:bennes/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print(data);
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print(notification);
  }
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String user;
  String palavra;
  String estadoAtual;
  String versao;

  initState() {
    super.initState();
    _checkUsernamePassword();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Accès non autorisé'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Vos références ne sont pas correctes'),
                Text(
                    "Essayez à nouveau!"),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Férmer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkUsernamePassword() async {
    String user = await Preferences.getString('user');
    String palavra = await Preferences.getString('palavra');
    setState(() {
      this.user = user;
      this.palavra = palavra;
      if (this.user != '') {
        nameController.text = this.user;
        passwordController.text = this.palavra;
      }
    });
  }

  void getcretenciais(user, palavra) async {
    var url = urlClient() +
        pasta() +
        '/aplicacao/login/login.php?user=' +
        user +
        '&palavra=' +
        palavra;
  
    var response = await http.get(url);
    String resposta = response.body.toString();
  print(resposta);
    var res = json.decode(resposta.toString());

    if (response.statusCode == 200) {
      String userName = res["user"];
      String passWord = res["palavra"];

      if (userName.trim() == user.trim() && passWord.trim() == palavra.trim()) {
        Preferences.setString('user', user);
        Preferences.setString('palavra', palavra);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StartWorkPage()),
        );
      } else {
        _showMyDialog();
      }
    } else {
      _showMyDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () {
        return new Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(51, 102, 153, 0.6),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 70.0,
                ),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),
                SizedBox(
                  height: 50.0,
                ),
           SizedBox(
                    height: 40.0,
                    child: Text(
                      'GESTION DE BENNES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(242, 242, 242, 0.8),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    )),
                     SizedBox(
                  height: 30.0,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:22, 
                    ),
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'utilisateur',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                     obscureText: true,
                   style: TextStyle(
                      color: Colors.black,
                      fontSize:22, 
                    ),
                    controller: passwordController,
                   decoration: InputDecoration(
                      hintText: 'mot de passe',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Color.fromRGBO(242, 242, 242, 0.6),
                      child: Text(
                        'se connecter',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                          conectividade();
                        getcretenciais(
                            nameController.text, passwordController.text);
                      },
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                    )),     
              ],
            )),
      ),
    );
  }
}
