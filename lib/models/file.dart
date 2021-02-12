class Folder {
  List<FileType> files = [];
  String folderName;

  Folder({this.files, this.folderName});

  static List<Folder> fromJson(List<dynamic> json) {
    List<Folder> folder = [];
    json.forEach((j) {
      folder.add(Folder(
        files: FileType.fromJson(j['files']),
        folderName: j['folderName'],
      ));
    });
    return folder;
  }
}

class FileType {
  String path;
  String title = '';
  String size = '';
  String mimeType = '';
  String album = '';
  String artist = '';
  String dateAdded = '';
  String duration = '';
  String displayName = '';

  FileType(this.path,
      {this.title,
      this.size,
      this.mimeType,
      this.album,
      this.artist,
      this.dateAdded,
      this.duration,
      this.displayName});

  static List<FileType> fromJson(List<dynamic> json) {
    List<FileType> list = [];
    json.forEach((j) {
      list.add(FileType(
        j,
      ));
    });
    return list;
  }
}
