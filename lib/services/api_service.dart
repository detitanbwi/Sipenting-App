import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://sipenting.bondowosokab.go.id/api';
  static String? token;

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// Load token dari secure storage ke memory
  static Future<void> loadToken() async {
    token = await _storage.read(key: _tokenKey);
  }

  /// Hapus token dari memory dan secure storage (logout)
  static Future<void> clearToken() async {
    token = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Fetch list of Kabupaten (GET /kabupaten)
  static Future<List<dynamic>> getKabupaten() async {
    final url = Uri.parse('$baseUrl/kabupaten');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      } else if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception(
        'Gagal memuat data kabupaten (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetch list of Kecamatan (GET /kecamatan?id_kabupaten=xxxx)
  static Future<List<dynamic>> getKecamatan({String? idKabupaten}) async {
    final query = idKabupaten != null ? '?id_kabupaten=$idKabupaten' : '';
    final url = Uri.parse('$baseUrl/kecamatan$query');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      } else if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception(
        'Gagal memuat data kecamatan (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetch list of Desa under specific Kecamatan (POST /desa)
  static Future<List<dynamic>> getDesa(String idKecamatan) async {
    final url = Uri.parse('$baseUrl/desa');
    final request = http.MultipartRequest('POST', url);
    request.fields['id_kecamatan'] = idKecamatan;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      } else if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception(
        'Gagal memuat data desa (Status: ${response.statusCode})',
      );
    }
  }

  /// User Login (POST /login)
  static Future<Map<String, dynamic>> login(String username) async {
    final url = Uri.parse('$baseUrl/login');
    final request = http.MultipartRequest('POST', url);
    request.fields['username'] = username;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        token = decoded['access_token'];
        // Simpan token ke secure storage agar persist setelah restart
        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        return decoded;
      }
      return {'status': true, 'message': 'Login berhasil'};
    } else {
      String errorMessage = 'Login gagal';
      if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'];
      }
      throw Exception(errorMessage);
    }
  }

  /// User Register (POST /register)
  static Future<Map<String, dynamic>> register({
    required String username,
    required String namaIbu,
    required String idDesa,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final request = http.MultipartRequest('POST', url);
    request.fields['username'] = username;
    request.fields['namaIbu'] = namaIbu;
    request.fields['id_desa'] = idDesa;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': true, 'message': 'Registrasi berhasil'};
    } else {
      String errorMessage = 'Registrasi gagal';
      if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'];
      }
      throw Exception(errorMessage);
    }
  }

  /// Logout (POST /logout) — invalidate token di server lalu hapus lokal
  static Future<void> logout() async {
    try {
      final url = Uri.parse('$baseUrl/logout');
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
      });
      await request.send().timeout(const Duration(seconds: 10));
    } catch (_) {
      // Tidak fatal — token lokal tetap dihapus meski server error
    } finally {
      await clearToken();
    }
  }

  /// Update profile user (POST /updateProfile)
  /// Field yang bisa diupdate: namaIbu, tanggalLahir, tinggiBadan, bbPraHamil
  /// username (NIK) harus selalu dikirim agar backend tidak set null
  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String namaIbu,
    String? tanggalLahir,
    String? tinggiBadan,
    String? bbPraHamil,
  }) async {
    final url = Uri.parse('$baseUrl/updateProfile');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    // username (NIK) wajib dikirim — backend selalu update nik, username & password dari field ini
    request.fields['username'] = username;
    request.fields['namaIbu'] = namaIbu;
    if (tanggalLahir != null && tanggalLahir.isNotEmpty) {
      request.fields['tanggalLahir'] = tanggalLahir;
    }
    if (tinggiBadan != null && tinggiBadan.isNotEmpty) {
      request.fields['tinggiBadan'] = tinggiBadan;
    }
    if (bbPraHamil != null && bbPraHamil.isNotEmpty) {
      request.fields['bbPraHamil'] = bbPraHamil;
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'status': 'success', 'message': 'Profil berhasil diperbarui'};
    } else {
      String errorMessage = 'Gagal memperbarui profil';
      if (decoded is Map && decoded.containsKey('message')) {
        errorMessage = decoded['message'];
      }
      throw Exception(errorMessage);
    }
  }

  /// Fetch list of articles (GET /artikel) with optional category filter
  static Future<List<dynamic>> getArticles({String? category}) async {
    final query = category != null && category.isNotEmpty
        ? '?kategori=$category'
        : '';
    final url = Uri.parse('$baseUrl/artikel$query');
    final response = await http
        .get(
          url,
          headers: {
            'Accept': 'application/json',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        log(decoded['data'].toString());
        return decoded['data'] ?? [];
      } else if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception('Gagal memuat artikel (Status: ${response.statusCode})');
    }
  }

  /// Get User Profile (GET /getuser)
  static Future<Map<String, dynamic>> getUser() async {
    final url = Uri.parse('$baseUrl/getuser');
    final response = await http
        .get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? {};
      }
      return decoded;
    } else {
      throw Exception('Gagal memuat profil (Status: ${response.statusCode})');
    }
  }

  /// Fetch list of babies (GET /bayi)
  static Future<List<dynamic>> getBayi() async {
    final url = Uri.parse('$baseUrl/bayi');
    final response = await http
        .get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      }
      return [];
    } else {
      throw Exception(
        'Gagal memuat data bayi (Status: ${response.statusCode})',
      );
    }
  }

  /// Fetch list of foods (GET /kalkulatorGizi)
  static Future<List<dynamic>> getMakanan() async {
    final url = Uri.parse('$baseUrl/kalkulatorGizi');
    final response = await http
        .get(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      }
      return [];
    } else {
      throw Exception('Gagal memuat makanan (Status: ${response.statusCode})');
    }
  }

  /// Calculate child nutrition status (POST /kalkulatorGizi/cekGizi)
  static Future<Map<String, dynamic>> cekGizi({
    required String idBayi,
    required String data,
  }) async {
    final url = Uri.parse('$baseUrl/kalkulatorGizi/cekGizi');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;
    request.fields['data'] = data;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'success', 'message': 'Gizi berhasil dihitung'};
    } else {
      throw Exception(decoded['message'] ?? 'Gagal menghitung gizi');
    }
  }

  /// Calculate child stunting status (POST /kalkulatorStunting/cekStuntingAnak)
  static Future<Map<String, dynamic>> cekStuntingAnak({
    required String idBayi,
    required String tinggiBadan,
  }) async {
    final url = Uri.parse('$baseUrl/kalkulatorStunting/cekStuntingAnak');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;
    request.fields['tinggiBadan'] = tinggiBadan;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        'status': 'success',
        'message': 'Status stunting berhasil dihitung',
      };
    } else {
      throw Exception(decoded['message'] ?? 'Gagal menghitung stunting');
    }
  }

  /// Add a new baby (POST /bayi/storeBayi)
  static Future<Map<String, dynamic>> storeBayi({
    required String nama,
    required String tanggalLahir,
    required String kelamin,
  }) async {
    final url = Uri.parse('$baseUrl/bayi/storeBayi');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['nama'] = nama;
    request.fields['tanggalLahir'] = tanggalLahir;
    request.fields['kelamin'] = kelamin;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'success', 'message': 'Data bayi berhasil disimpan'};
    } else {
      throw Exception(decoded['message'] ?? 'Gagal menyimpan data bayi');
    }
  }

  /// Delete a baby (POST /bayi/deleteBayi)
  static Future<Map<String, dynamic>> deleteBayi(String idBayi) async {
    final url = Uri.parse('$baseUrl/bayi/deleteBayi');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 10),
    );
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'success', 'message': 'Data bayi berhasil dihapus'};
    } else {
      throw Exception(decoded['message'] ?? 'Gagal menghapus data bayi');
    }
  }
}
