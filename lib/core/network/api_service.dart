import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../utils/constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET('/sales')
  Future<List<Map<String, dynamic>>> getSales();

  @GET('/sales/{id}')
  Future<Map<String, dynamic>> getSaleById(@Path('id') String id);

  @POST('/sales')
  Future<Map<String, dynamic>> createSale(@Body() Map<String, dynamic> sale);

  @PUT('/sales/{id}')
  Future<Map<String, dynamic>> updateSale(
    @Path('id') String id,
    @Body() Map<String, dynamic> sale,
  );

  @DELETE('/sales/{id}')
  Future<void> deleteSale(@Path('id') String id);
}
