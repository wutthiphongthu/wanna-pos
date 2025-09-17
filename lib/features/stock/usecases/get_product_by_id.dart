import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProductById implements UseCase<ProductModel?, int> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<Either<Failure, ProductModel?>> call(int id) async {
    return await repository.getProductById(id);
  }
}
