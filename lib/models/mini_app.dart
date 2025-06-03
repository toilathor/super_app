class MiniApp {
  final String id;
  final String name;
  final String link;
  final bool isEnable;
  final int version;
  final int currentVersion;
  final String checksum;
  bool needDownload;

  MiniApp({
    required this.id,
    required this.name,
    required this.link,
    required this.isEnable,
    required this.currentVersion,
    required this.version,
    required this.checksum,
    required this.needDownload,
  });

  void setNeedDownload(bool value) {
    needDownload = value;
  }
}
