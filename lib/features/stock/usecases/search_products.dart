import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class SearchProducts implements UseCase<List<ProductModel>, String> {
  final ProductRepository repository;

  SearchProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductModel>>> call(String searchTerm) async {
    return await repository.searchProducts(searchTerm);
  }
}
