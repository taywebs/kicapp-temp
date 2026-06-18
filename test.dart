import 'dart:convert';
void main() {
  String jsonString = '{"id":"3e511e23-a3db-4533-813e-51f622988bb7","parent_id":"0","name":"Coffe","image":"2026-06-16-6a3111ff835e0.png","position":1,"description":null,"is_active":1,"is_featured":1,"created_at":"2026-06-16T09:06:07.000000Z","updated_at":"2026-06-16T09:36:05.000000Z","category_type":"directory_listing","dynamic_schema":["menu","working_hours","wifi_available","delivery"],"image_full_path":"http://localhost/storage/category/2026-06-16-6a3111ff835e0.png","category_discount":[],"campaign_discount":[],"translations":[{"id":90,"translationable_type":"Modules\\CategoryManagement\\Entities\\Category","translationable_id":"3e511e23-a3db-4533-813e-51f622988bb7","locale":"en","key":"name","value":"Coffe"}],"storage":null}';
  Map<String, dynamic> json = jsonDecode(jsonString);
  try {
    print("isActive: ${int.tryParse(json['is_active'].toString()) == 1 ? true : false}");
    print("servicesCount: ${int.tryParse(json['services_count'].toString())}");
    print("categoryType: ${json['category_type'] ?? 'service'}");
    print("Success!");
  } catch(e) {
    print("Error: $e");
  }
}
