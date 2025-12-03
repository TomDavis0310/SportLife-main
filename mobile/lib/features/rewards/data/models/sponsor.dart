import 'package:json_annotation/json_annotation.dart';

part 'sponsor.g.dart';

@JsonSerializable()
class Sponsor {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;

  Sponsor({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.isActive = true,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) =>
      _$SponsorFromJson(json);
  Map<String, dynamic> toJson() => _$SponsorToJson(this);
}

