import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_template.dart';
import '../bloc/admin_bloc.dart';
import 'admin_template_form.dart';

class AdminTemplatesTab extends StatelessWidget {
  final List<AdminTemplate> templates;

  const AdminTemplatesTab({super.key, required this.templates});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: templates.isEmpty
          ? const Center(
              child: Text(
                "No templates found.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: template.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(template.thumbnailUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[800],
                      ),
                      child: template.thumbnailUrl.isEmpty
                          ? const Icon(Icons.image, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      template.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Price: ₹${template.price} | Views: ${template.viewCount}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue[300]),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AdminBloc>(),
                                  child: AdminTemplateForm(template: template),
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            template.isActive
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: template.isActive
                                ? Colors.greenAccent
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (template.isActive) {
                              context.read<AdminBloc>().add(
                                DeleteTemplateEvent(template.id),
                              );
                            } else {
                              // Restore logic if implemented, or just re-enable?
                              // For now DeleteTemplate is soft delete.
                              // To restore, we might need UpdateTemplateEvent with isActive=true
                              final updated = AdminTemplate(
                                id: template.id,
                                title: template.title,
                                description: template.description,
                                thumbnailUrl: template.thumbnailUrl,
                                youtubeId: template.youtubeId,
                                category: template.category,
                                tags: template.tags,
                                price: template.price,
                                viewCount: template.viewCount,
                                isActive: true,
                              );
                              context.read<AdminBloc>().add(
                                UpdateTemplateEvent(updated),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "admin_add_template_btn",
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AdminBloc>(),
                child: const AdminTemplateForm(),
              ),
            ),
          );
        },
      ),
    );
  }
}
