import 'package:equatable/equatable.dart';
import '../models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<ProductModel>? searchResults;
  final ProductModel? selectedProduct;
  final String? searchTerm;

  const ProductLoaded({
    required this.products,
    this.searchResults,
    this.selectedProduct,
    this.searchTerm,
  });

  @override
  List<Object?> get props => [products, searchResults, selectedProduct, searchTerm];

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? searchResults,
    ProductModel? selectedProduct,
    String? searchTerm,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      searchResults: searchResults ?? this.searchResults,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  final List<ProductModel> products;

  const ProductOperationSuccess({
    required this.message,
    required this.products,
  });

  @override
  List<Object?> get props => [message, products];
}

class ProductOperationFailure extends ProductState {
  final String message;
  final List<ProductModel> products;

  const ProductOperationFailure({
    required this.message,
    required this.products,
  });

  @override
  List<Object?> get props => [message, products];
}
