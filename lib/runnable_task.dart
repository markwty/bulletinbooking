import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class RunnableTask{
  String address;
  String result = "";

  RunnableTask(this.address);

  Future run() async {
    http.Client httpClient = new http.Client();
    try{
      Response request = await httpClient.get(Uri.parse(this.address));
      if (request.statusCode == 200) {
        result = request.body;
      } else {
        print("$runtimeType: Can't get http results");
        result = "";
      }
    } catch(e) {
      print("$runtimeType: $e, ${this.address}");
    } finally {
      httpClient.close();
    }
  }
}