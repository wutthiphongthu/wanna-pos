import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';

/// รายละเอียดบิล (หัวบิล + รายการ)
class SaleDetailDto {
  final SaleEntity sale;
  final List<SaleLineItemEntity> lineItems;

  SaleDetailDto({required this.sale, required this.lineItems});
}
