import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class DeleteProduct implements UseCase<int, ProductModel> {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, int>> call(ProductModel product) async {
    return await repository.deleteProduct(product);
  }
}
