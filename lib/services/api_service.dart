import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://sipenting.bondowosokab.go.id/api';
  static String? token;

  /// Fetch list of Kecamatan (GET /kecamatan)
  static Future<List<dynamic>> getKecamatan() async {
    final url = Uri.parse('$baseUrl/kecamatan');
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
      throw Exception('Gagal memuat data kecamatan (Status: ${response.statusCode})');
    }
  }

  /// Fetch list of Desa under specific Kecamatan (POST /desa)
  static Future<List<dynamic>> getDesa(String idKecamatan) async {
    final url = Uri.parse('$baseUrl/desa');
    final request = http.MultipartRequest('POST', url);
    request.fields['id_kecamatan'] = idKecamatan;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
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
      throw Exception('Gagal memuat data desa (Status: ${response.statusCode})');
    }
  }

  /// User Login (POST /login)
  static Future<Map<String, dynamic>> login(String username) async {
    final url = Uri.parse('$baseUrl/login');
    final request = http.MultipartRequest('POST', url);
    request.fields['username'] = username;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        token = decoded['access_token'];
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

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
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

  /// Fetch list of articles (GET /artikel) with optional category filter
  static Future<List<dynamic>> getArticles({String? category}) async {
    final query = category != null && category.isNotEmpty ? '?kategori=$category' : '';
    final url = Uri.parse('$baseUrl/artikel$query');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
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
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
      },
    ).timeout(const Duration(seconds: 10));

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
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] ?? [];
      }
      return [];
    } else {
      throw Exception('Gagal memuat data bayi (Status: ${response.statusCode})');
    }
  }

  /// Fetch list of foods (GET /kalkulatorGizi)
  static Future<List<dynamic>> getMakanan() async {
    final url = Uri.parse('$baseUrl/kalkulatorGizi');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
      },
    ).timeout(const Duration(seconds: 10));

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
  static Future<Map<String, dynamic>> cekGizi({required String idBayi, required String data}) async {
    final url = Uri.parse('$baseUrl/kalkulatorGizi/cekGizi');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;
    request.fields['data'] = data;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
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
  static Future<Map<String, dynamic>> cekStuntingAnak({required String idBayi, required String tinggiBadan}) async {
    final url = Uri.parse('$baseUrl/kalkulatorStunting/cekStuntingAnak');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;
    request.fields['tinggiBadan'] = tinggiBadan;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
    final response = await http.Response.fromStream(streamedResponse);

    final decoded = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'success', 'message': 'Status stunting berhasil dihitung'};
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
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['nama'] = nama;
    request.fields['tanggalLahir'] = tanggalLahir;
    request.fields['kelamin'] = kelamin;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
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
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0/SipentingApp',
    });
    request.fields['idBayi'] = idBayi;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
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
