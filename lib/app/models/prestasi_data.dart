class PrestasiData {
  final String id;
  final String userId;
  final String nama;
  final String namaPrestasi;
  final String jabatanPemberi;
  final String namaPemberi;
  final String nomorSertifikat;
  final String? buktiUrl;
  final String buktiFileName;
  final DateTime createdAt;

  PrestasiData({
    required this.id,
    required this.userId,
    required this.nama,
    required this.namaPrestasi,
    required this.jabatanPemberi,
    required this.namaPemberi,
    required this.nomorSertifikat,
    this.buktiUrl,
    required this.buktiFileName,
    required this.createdAt,
  });

  factory PrestasiData.fromFirestore(Map<String, dynamic> data, String id) {
    return PrestasiData(
      id: id,
      userId: data['userId'] ?? '',
      nama: data['nama'] ?? '',
      namaPrestasi: data['namaPrestasi'] ?? '',
      jabatanPemberi: data['jabatanPemberi'] ?? '',
      namaPemberi: data['namaPemberi'] ?? '',
      nomorSertifikat: data['nomorSertifikat'] ?? '',
      buktiUrl: data['buktiUrl'],
      buktiFileName: data['buktiFileName'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'nama': nama,
      'namaPrestasi': namaPrestasi,
      'jabatanPemberi': jabatanPemberi,
      'namaPemberi': namaPemberi,
      'nomorSertifikat': nomorSertifikat,
      'buktiUrl': buktiUrl,
      'buktiFileName': buktiFileName,
      'createdAt': createdAt,
    };
  }
}