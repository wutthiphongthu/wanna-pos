import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/usecase/usecase.dart';
import '../usecases/create_product.dart' as create_product;
import '../usecases/delete_product.dart' as delete_product;
import '../usecases/get_active_products.dart' as get_active_products;
import '../usecases/get_all_products.dart' as get_all_products;
import '../usecases/get_low_stock_products.dart' as get_low_stock_products;
import '../usecases/get_product_by_id.dart' as get_product_by_id;
import '../usecases/search_products.dart' as search_products;
import '../usecases/update_product.dart' as update_product;
import '../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final get_all_products.GetAllProducts _getAllProducts;
  final get_active_products.GetActiveProducts _getActiveProducts;
  final get_product_by_id.GetProductById _getProductById;
  final search_products.SearchProducts _searchProducts;
  final create_product.CreateProduct _createProduct;
  final update_product.UpdateProduct _updateProduct;
  final delete_product.DeleteProduct _deleteProduct;
  final get_low_stock_products.GetLowStockProducts _getLowStockProducts;
  final ProductRepository _productRepository;

  ProductBloc(
    this._getAllProducts,
    this._getActiveProducts,
    this._getProductById,
    this._searchProducts,
    this._createProduct,
    this._updateProduct,
    this._deleteProduct,
    this._getLowStockProducts,
    this._productRepository,
  ) : super(const ProductInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadActiveProducts>(_onLoadActiveProducts);
    on<LoadProductById>(_onLoadProductById);
    on<SearchProductsEvent>(_onSearchProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<LoadLowStockProducts>(_onLoadLowStockProducts);
    on<UpdateStockQuantity>(_onUpdateStockQuantity);
    on<ToggleProductStatus>(_onToggleProductStatus);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getAllProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  Future<void> _onLoadActiveProducts(
    LoadActiveProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getActiveProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  Future<void> _onLoadProductById(
    LoadProductById event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _getProductById(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) {
        if (state is ProductLoaded) {
          final currentState = state as ProductLoaded;
          emit(currentState.copyWith(selectedProduct: product));
        }
      },
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (event.searchTerm.isEmpty) {
      add(const ClearSearch());
      return;
    }

    final result = await _searchProducts(event.searchTerm);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (searchResults) {
        if (state is ProductLoaded) {
          final currentState = state as ProductLoaded;
          emit(currentState.copyWith(
            searchResults: searchResults,
            searchTerm: event.searchTerm,
          ));
        } else {
          emit(ProductLoaded(
            products: [],
            searchResults: searchResults,
            searchTerm: event.searchTerm,
          ));
        }
      },
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _createProduct(event.product);
    result.fold(
      (failure) => emit(ProductOperationFailure(
        message: failure.message,
        products:
            state is ProductLoaded ? (state as ProductLoaded).products : [],
      )),
      (productId) async {
        // Reload products after creation
        add(const LoadAllProducts());
        emit(ProductOperationSuccess(
          message: 'สินค้าถูกเพิ่มเรียบร้อยแล้ว',
          products:
              state is ProductLoaded ? (state as ProductLoaded).products : [],
        ));
      },
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductOperationFailure(
        message: failure.message,
        products:
            state is ProductLoaded ? (state as ProductLoaded).products : [],
      )),
      (rowsAffected) async {
        // Reload products after update
        add(const LoadAllProducts());
        emit(ProductOperationSuccess(
          message: 'สินค้าถูกอัปเดตเรียบร้อยแล้ว',
          products:
              state is ProductLoaded ? (state as ProductLoaded).products : [],
        ));
      },
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _deleteProduct(event.product);
    result.fold(
      (failure) => emit(ProductOperationFailure(
        message: failure.message,
        products:
            state is ProductLoaded ? (state as ProductLoaded).products : [],
      )),
      (rowsAffected) async {
        // Reload products after deletion
        add(const LoadAllProducts());
        emit(ProductOperationSuccess(
          message: 'สินค้าถูกลบเรียบร้อยแล้ว',
          products:
              state is ProductLoaded ? (state as ProductLoaded).products : [],
        ));
      },
    );
  }

  Future<void> _onLoadLowStockProducts(
    LoadLowStockProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await _getLowStockProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  Future<void> _onUpdateStockQuantity(
    UpdateStockQuantity event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _productRepository.updateStockQuantity(
      event.productId,
      event.newQuantity,
    );
    result.fold(
      (failure) => emit(ProductOperationFailure(
        message: failure.message,
        products:
            state is ProductLoaded ? (state as ProductLoaded).products : [],
      )),
      (rowsAffected) async {
        // Reload products after stock update
        add(const LoadAllProducts());
        emit(ProductOperationSuccess(
          message: 'จำนวนสินค้าถูกอัปเดตเรียบร้อยแล้ว',
          products:
              state is ProductLoaded ? (state as ProductLoaded).products : [],
        ));
      },
    );
  }

  Future<void> _onToggleProductStatus(
    ToggleProductStatus event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _productRepository.updateProductStatus(
      event.productId,
      event.isActive,
    );
    result.fold(
      (failure) => emit(ProductOperationFailure(
        message: failure.message,
        products:
            state is ProductLoaded ? (state as ProductLoaded).products : [],
      )),
      (rowsAffected) async {
        // Reload products after status update
        add(const LoadAllProducts());
        emit(ProductOperationSuccess(
          message: 'สถานะสินค้าถูกอัปเดตเรียบร้อยแล้ว',
          products:
              state is ProductLoaded ? (state as ProductLoaded).products : [],
        ));
      },
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(
        searchResults: null,
        searchTerm: null,
      ));
    }
  }
}
