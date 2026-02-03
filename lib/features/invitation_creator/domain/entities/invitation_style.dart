import 'package:equatable/equatable.dart';

class InvitationStyle extends Equatable {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String videoTemplateId; // YouTube ID for the template video
  final List<String> categories;

  const InvitationStyle({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.videoTemplateId,
    required this.categories,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    thumbnailUrl,
    videoTemplateId,
    categories,
  ];
}
