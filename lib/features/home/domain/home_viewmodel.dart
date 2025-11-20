import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  List savedProducts = [];

  Future<void> getSavedProducts() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('users') // your table name
        .select('saved_products') // the column you want
        .eq('id', "38137b44-3955-4ec9-b47a-7398aef87da3") // match by ID
        .maybeSingle(); // return only one row

    savedProducts = response!['saved_products'];

    notifyListeners();
  }
}
