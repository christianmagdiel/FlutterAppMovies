import 'package:http/http.dart' as http;
import 'package:movies/src/models/actores_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:movies/src/models/pelicula_model.dart';

class PeliculasProvider {
  String _apiKey = '9912e78d47b96491ecfe8d49749617ff';
  String _url = 'api.themoviedb.org';
  String _languaje = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;
  List<Pelicula> _populares = new List();
  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  void disposeStreams(){
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async{
    final resp =await http.get(url);
    final decodedData = json.decode(resp.body);

    final peliculas = new Peliculas.fromJsonList(decodedData['results']);

    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async{

    final url = Uri.https(_url, '3/movie/now_playing',{
      'api_key'   : _apiKey,
      'language'  : _languaje
    });

    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async{

    if(_cargando) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular',{
      'api_key'   : _apiKey,
      'language'  : _languaje,
      'page'      : _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);
    popularesSink(_populares);
    _cargando= false;
    return resp;
  }

  Future<List<Actor>> getCast( String peliculaId) async{
    final url = Uri.https(_url, '3/movie/$peliculaId/credits',{
      'api_key'   : _apiKey,
      'languaje'  : _languaje
    });

    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async{

    final url = Uri.https(_url, '3/search/movie',{
      'api_key'   : _apiKey,
      'language'  : _languaje,
      'query'     : query
    });

    return await _procesarRespuesta(url);
  }
  
}