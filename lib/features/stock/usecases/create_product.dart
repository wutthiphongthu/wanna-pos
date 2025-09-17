import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class CreateProduct implements UseCase<int, ProductModel> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, int>> call(ProductModel product) async {
    return await repository.insertProduct(product);
  }
}
