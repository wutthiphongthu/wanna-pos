import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

@injectable
class GetLowStockProducts implements UseCase<List<ProductModel>, NoParams> {
  final ProductRepository repository;

  GetLowStockProducts(this.repository);

  @override
  Future<Either<Failure, List<ProductModel>>> call(NoParams params) async {
    return await repository.getLowStockProducts();
  }
}
