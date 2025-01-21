class AppVersion {
  final int buildNumber;
  var _versionCode;
  String tenantId;
  String buildDate;
  String versionName;
  String remoteUrl;
  String appName;
  String packageName;

  Map<String, dynamic> previousVersion;
  bool forceUpdate;

  // Rollback the application to a previous state
  bool _rollback;

  // Is this a stable release
  bool _isStable;

  get versionCode => _versionCode;

  AppVersion(
    this.buildNumber, {
    this.versionName,
    String versionCode,
    this.remoteUrl,
    this.packageName,
    this.tenantId,
    this.appName,
  }) : _versionCode = versionCode;

  factory AppVersion.fromMap(Map<String, dynamic> data) {
    return AppVersion(
      data['buildNumber'],
      packageName: data['packageName'],
      tenantId: data['tenantId'],
      appName: data['appName'],
      versionCode: data['versionCode'],
      versionName: data['versionName'],
      remoteUrl: data['remoteUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        "versionCode": versionCode,
        "versionName": versionName,
        "url": remoteUrl,
      };
}
