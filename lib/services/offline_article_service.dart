import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class OfflineArticleService {
  static const String _savedIdsKey = 'saved_article_ids';

  /// Direktori penyimpanan artikel
  static Future<Directory> _getArticlesDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final articlesDir = Directory('${appDir.path}/articles');
    if (!await articlesDir.exists()) {
      await articlesDir.create(recursive: true);
    }
    return articlesDir;
  }

  /// Direktori penyimpanan thumbnail
  static Future<Directory> _getThumbsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbsDir = Directory('${appDir.path}/articles/thumbs');
    if (!await thumbsDir.exists()) {
      await thumbsDir.create(recursive: true);
    }
    return thumbsDir;
  }

  /// Download dan simpan thumbnail dari URL ke local file
  static Future<String?> saveThumbnail(String id, String imageUrl) async {
    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final dir = await _getThumbsDir();
        final file = File('${dir.path}/$id.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {
      // Gagal download thumbnail — tidak fatal
    }
    return null;
  }

  /// Ambil path thumbnail lokal berdasarkan ID
  static Future<String?> getThumbnailPath(String id) async {
    if (id.isEmpty) return null;
    final dir = await _getThumbsDir();
    final file = File('${dir.path}/$id.jpg');
    if (await file.exists()) return file.path;
    return null;
  }

  /// Hapus thumbnail lokal
  static Future<void> deleteThumbnail(String id) async {
    final dir = await _getThumbsDir();
    final file = File('${dir.path}/$id.jpg');
    if (await file.exists()) await file.delete();
  }

  /// Simpan poster gambar artikel ke local file (key: {id}_poster.jpg)
  static Future<String?> savePoster(String id, String imageUrl) async {
    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final dir = await _getThumbsDir();
        final file = File('${dir.path}/${id}_poster.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (_) {
      // Gagal download poster — tidak fatal
    }
    return null;
  }

  /// Ambil path poster lokal berdasarkan ID artikel
  static Future<String?> getPosterPath(String id) async {
    if (id.isEmpty) return null;
    final dir = await _getThumbsDir();
    final file = File('${dir.path}/${id}_poster.jpg');
    if (await file.exists()) return file.path;
    return null;
  }

  /// Hapus poster lokal
  static Future<void> deletePoster(String id) async {
    final dir = await _getThumbsDir();
    final file = File('${dir.path}/${id}_poster.jpg');
    if (await file.exists()) await file.delete();
  }

  /// Simpan artikel ke local storage (beserta thumbnail YouTube & poster)
  static Future<void> saveArticle(Map<String, dynamic> article) async {
    final id = article['id']?.toString();
    if (id == null || id.isEmpty) return;

    // Gunakan YoutubePlayer.convertUrlToId untuk konsistensi dengan UI
    final urlVideo = article['url_video'] as String?;
    String? thumbnailUrl;

    if (urlVideo != null && urlVideo.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(urlVideo);
      if (videoId != null && videoId.isNotEmpty) {
        thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
      }
    }

    // Jika tidak ada video, simpan poster sebagai thumbnail juga (untuk card list)
    final gambar = article['gambar'] as String?;
    final posterUrl = (gambar != null && gambar.isNotEmpty && gambar != 'gambar2')
        ? 'https://sipenting.bondowosokab.go.id/storage/artikel/$gambar'
        : null;

    if (thumbnailUrl == null && posterUrl != null) {
      thumbnailUrl = posterUrl;
    }

    // Download & simpan thumbnail (YouTube atau poster fallback)
    if (thumbnailUrl != null) {
      await saveThumbnail(id, thumbnailUrl);
    }

    // Download & simpan poster secara terpisah (jika ada)
    if (posterUrl != null) {
      await savePoster(id, posterUrl);
    }

    // Simpan JSON artikel
    final dir = await _getArticlesDir();
    final file = File('${dir.path}/$id.json');
    await file.writeAsString(json.encode(article));

    // Simpan ID ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedIdsKey) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_savedIdsKey, ids);
    }
  }

  /// Hapus artikel dari local storage (termasuk thumbnail)
  static Future<void> deleteArticle(String id) async {
    final dir = await _getArticlesDir();
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) await file.delete();

    await deleteThumbnail(id);
    await deletePoster(id);

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedIdsKey) ?? [];
    ids.remove(id);
    await prefs.setStringList(_savedIdsKey, ids);
  }

  /// Cek apakah artikel sudah tersimpan
  static Future<bool> isArticleSaved(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedIdsKey) ?? [];
    return ids.contains(id);
  }

  /// Ambil semua artikel yang tersimpan
  static Future<List<Map<String, dynamic>>> getSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedIdsKey) ?? [];
    final dir = await _getArticlesDir();
    final articles = <Map<String, dynamic>>[];

    for (final id in ids) {
      final file = File('${dir.path}/$id.json');
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final article = json.decode(content) as Map<String, dynamic>;
          articles.add(article);
        } catch (_) {
          // Skip file yang corrupt
        }
      }
    }

    return articles;
  }

  /// Ambil satu artikel tersimpan berdasarkan ID
  static Future<Map<String, dynamic>?> getArticleById(String id) async {
    final dir = await _getArticlesDir();
    final file = File('${dir.path}/$id.json');
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Jumlah artikel tersimpan
  static Future<int> getSavedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedIdsKey) ?? [];
    return ids.length;
  }
}

