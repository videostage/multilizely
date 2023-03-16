import 'package:dio/dio.dart';

class LocalizelyApi {
  static const _baseUrl = "https://api.localizely.com";

  final String _uploadUrl;

  final String _downloadUrl;

  final Dio _dio;

  final String token;

  LocalizelyApi({
    required String projectId,
    required this.token,
  })  : _uploadUrl = "/v1/projects/$projectId/files/upload",
        _downloadUrl = "/v1/projects/$projectId/files/download",
        _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            headers: {"X-Api-Token": token},
          ),
        );

  Future upload(
    String filePath, {
    required String locale,
    bool overwrite = false,
    bool reviewed = false,
    List<String> tagsAdded = const [],
    List<String> tagsUpdated = const [],
  }) async =>
      _dio.post(
        _uploadUrl,
        data: FormData.fromMap({
          "file": await MultipartFile.fromFile(filePath),
        }),
        queryParameters: {
          "lang_code": locale,
          "overwrite": overwrite,
          "reviewed": reviewed,
          for (String tag in tagsAdded) "tag_added": tag,
          for (String tag in tagsUpdated) "tag_updated": tag,
        },
      );

  Future download(
    String path, {
    required String locale,
  }) =>
      _dio.download(_downloadUrl, "$path/strings_$locale.arb", queryParameters: {
        "lang_codes": locale,
        "type": "flutter_arb",
        "export_empty_as": "empty",
      });
}
