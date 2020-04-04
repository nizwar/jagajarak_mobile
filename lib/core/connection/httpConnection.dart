import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class HttpConnection {
  final BuildContext context;

  HttpConnection(this.context);
  
  Future get(String url, {Map<String, String> params, Map<String, dynamic> headers}) async {
    var resp = await Dio().get(url + _paramToString(params), options: Options(headers: headers));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return resp.data;
    }
    return null;
  }

  Future post(String url, {Map<String, dynamic> data, Map<String, dynamic> headers}) async { 
    var resp = await Dio().post(url, data: data, options: Options(headers: headers)); 
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return resp.data;
    }
    return null;
  }

  String _paramToString(Map<String, String> params) {
    if (params == null) return "";
    String output = "?";
    params.forEach((key, value) {
      output += "$key=$value&";
    });
    return output.substring(0, output.length - 1);
  }
}
