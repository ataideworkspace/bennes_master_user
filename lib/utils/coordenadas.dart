import 'package:bennes/utils/pasta.dart';
import 'package:bennes/utils/url.dart';
import 'package:http/http.dart' as http;


posicaoCoordenadas(latitude, longitude, user) async {
  var url = urlClient() +
      pasta() + "/aplicacao/delivery/updateCoordenadas.php?latitude=" + latitude + '&longitude=' + longitude + '&user=' + user;
  var response = await http.get(url);

  if (response.statusCode == 200) {
  print(response.statusCode);
  } else {
  print(response.statusCode);
  print(url);
  }
}
