import 'package:equatable/equatable.dart';
import '../models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProducts extends ProductEvent {
  const LoadAllProducts();
}

class LoadActiveProducts extends ProductEvent {
  const LoadActiveProducts();
}

class LoadProductById extends ProductEvent {
  final int id;

  const LoadProductById(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchProductsEvent extends ProductEvent {
  final String searchTerm;

  const SearchProductsEvent(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class CreateProductEvent extends ProductEvent {
  final ProductModel product;

  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final ProductModel product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final ProductModel product;

  const DeleteProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class LoadLowStockProducts extends ProductEvent {
  const LoadLowStockProducts();
}

class UpdateStockQuantity extends ProductEvent {
  final int productId;
  final int newQuantity;

  const UpdateStockQuantity(this.productId, this.newQuantity);

  @override
  List<Object?> get props => [productId, newQuantity];
}

class ToggleProductStatus extends ProductEvent {
  final int productId;
  final bool isActive;

  const ToggleProductStatus(this.productId, this.isActive);

  @override
  List<Object?> get props => [productId, isActive];
}

class ClearSearch extends ProductEvent {
  const ClearSearch();
}
