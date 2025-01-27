import 'package:supabase_flutter/supabase_flutter.dart';

class CrudServices {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> loadPegawai() async {
    final response = await _supabase
        .from('user')
        .select()
        .eq('role', 'pegawai')
        .order('userid');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> loadPelanggan() async {
    final response =
        await _supabase.from('pelanggan').select().order('pelangganid');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addPegawai(String username, String password) async {
    await _supabase.from('user').insert({
      'username': username,
      'password': password,
      'role': 'pegawai',
    });
  }

  static Future<void> addPelanggan(
      String nama, String alamat, String noTelp) async {
    await _supabase.from('pelanggan').insert({
      'nama': nama,
      'alamat': alamat,
      'no_tlp': noTelp,
    });
  }

  static Future<void> updatePegawai(
      int id, String username, String password) async {
    final Map<String, dynamic> updateData = {
      'username': username,
    };

    // Only update password if it's not empty
    if (password.isNotEmpty) {
      updateData['password'] = password;
    }

    await _supabase.from('user').update(updateData).eq('userid', id);
  }

  static Future<void> updatePelanggan(
      int id, String nama, String alamat, String noTelp) async {
    await _supabase.from('pelanggan').update({
      'nama': nama,
      'alamat': alamat,
      'no_tlp': noTelp,
    }).eq('pelangganid', id);
  }

  static Future<void> deletePegawai(int id) async {
    await _supabase.from('user').delete().eq('userid', id);
  }

  static Future<void> deletePelanggan(int id) async {
    await _supabase.from('pelanggan').delete().eq('pelangganid', id);
  }
}
