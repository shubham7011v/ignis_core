enum TemplateCategory {
  traditional,
  modern,
  minimal;

  String get displayName {
    switch (this) {
      case TemplateCategory.traditional:
        return 'Traditional';
      case TemplateCategory.modern:
        return 'Modern';
      case TemplateCategory.minimal:
        return 'Minimal';
    }
  }

  static TemplateCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'traditional':
        return TemplateCategory.traditional;
      case 'modern':
        return TemplateCategory.modern;
      case 'minimal':
        return TemplateCategory.minimal;
      default:
        return TemplateCategory.modern; // Default
    }
  }

  String toServerString() {
    switch (this) {
      case TemplateCategory.traditional:
        return 'Traditional';
      case TemplateCategory.modern:
        return 'Modern';
      case TemplateCategory.minimal:
        return 'Minimal';
    }
  }
}
