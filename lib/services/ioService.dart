import 'dart:io';
import 'package:path_provider/path_provider.dart';

class IOService {
  ///* Recupera o path do arquivo que irá armazenar os dados em formato json
  static Future<File> getFile(String nomeArquivo) async {
    var diretorio;
    if (Platform.isAndroid) {
      diretorio = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      diretorio = await getApplicationDocumentsDirectory();
    } else {
      return null;
    }
    var arquivo = File("${diretorio.path}/$nomeArquivo.json");
    return arquivo;
  }

  ///* Lê o arquivo json armazenado e o retorna em formato String
  static Future<String> lerArquivo(String nomeArquivo) async {
    try {
      var arquivo = await IOService.getFile(nomeArquivo);
      if (await arquivo.exists()) {
        return arquivo.readAsString();
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
