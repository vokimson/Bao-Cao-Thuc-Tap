// ignore_for_file: public_member_api_docs, sort_constructors_first
class Product {
  final int productId;
  final String name;
  final String series;
  final String screen;
  final String cpu;
  final String ram;
  final String hardware;
  final String graphicCard;
  final String operatingSystem;
  final int warranty;
  final String battery;
  final String weight;
  final String content;
  final String picture;
  final DateTime createDate;
  final int manufacturerId;
  final int vendorId;
  final int taxId;

  Product({
    required this.productId,
    required this.name,
    required this.series,
    required this.screen,
    required this.cpu,
    required this.ram,
    required this.hardware,
    required this.graphicCard,
    required this.operatingSystem,
    required this.warranty,
    required this.battery,
    required this.weight,
    required this.content,
    required this.picture,
    required this.createDate,
    required this.manufacturerId,
    required this.vendorId,
    required this.taxId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      name: json['name'],
      series: json['series'],
      screen: json['screen'],
      cpu: json['cpu'],
      ram: json['ram'],
      hardware: json['hardware'],
      graphicCard: json['graphic_card'],
      operatingSystem: json['operating_system'],
      warranty: json['warranty'],
      battery: json['battery'],
      weight: json['weight'],
      content: json['content'],
      picture: json['picture'],
      createDate: DateTime.parse(json['create_date']),
      manufacturerId: json['manufacturer_id'],
      vendorId: json['vendor_id'],
      taxId: json['tax_id'],
    );
  }
}
