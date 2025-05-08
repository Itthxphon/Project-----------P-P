class Printer {
  int id = 0;
  String name = "";
  String ip = "";
  String type = "";
  bool active = true;

  Printer({
    required this.id,
    required this.name,
    required this.ip,
    required this.type,
    required this.active,
  });

  factory Printer.fromJson(Map<String, dynamic> json) {
    return Printer(
      id: json['id'],
      name: json['name'],
      ip: json['ip'],
      type: json['type'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "id": this.id,
      "name": this.name,
      "ip": this.ip,
      "type": this.type,
      "active": this.active,
    };

    return json;
  }
}
