import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

@injectable
class GetSales implements UseCase<List<Sale>, NoParams> {
  final SalesRepository repository;

  GetSales(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(NoParams params) async {
    return await repository.getSales();
  }
}
