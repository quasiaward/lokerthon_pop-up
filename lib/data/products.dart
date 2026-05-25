import '../models/product.dart';
import 'place_info.dart';

final products = [
  for (final menu in featuredMenus)
    ProductPreview(
      id: menu.id,
      name: menu.name,
      subtitle: menu.subtitle,
      description: menu.description,
      tags: menu.tags,
      accent: menu.accent,
      motif: menu.motif,
    ),
];

final productNameById = {
  for (final product in products) product.id: product.name,
};
