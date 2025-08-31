import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/subscription/domain/models/subscription_transaction_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class TransactionDetailsBottomSheet extends StatelessWidget {
  final Transactions transactions;
  const TransactionDetailsBottomSheet({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusExtraLarge),
              topRight: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: Column(children: [

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Column(children: [

              Text('${'transaction_successful'.tr}!', style: cairoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6))),

              Text('${'for'.tr} ${transactions.package!.packageName} ${'package'.tr}', style: cairoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'purchase_status'.tr} : ', style: cairoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                Text(
                  transactions.planType == 'renew' ? 'renewed'.tr : transactions.planType == 'new_plan' ? 'migrated'.tr : transactions.planType == 'free_trial' ? 'free_trial'.tr : 'purchased'.tr,
                  style: cairoBold.copyWith(color: Theme.of(context).primaryColor),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(transactions.store?.name ?? '', style: cairoBold.copyWith(fontSize: 15)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(text: 'thank_you_for_transaction_with'.tr, style: cairoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  TextSpan(text: ' ${AppConstants.appName} ', style: cairoBold.copyWith(color: Theme.of(context).primaryColor)),
                  TextSpan(text: '${'in'.tr} ${transactions.package!.packageName} ${'package'.tr}', style: cairoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                ]),
              ),

            ]),
            const SizedBox(height: 40),

          ]),
        ),

        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('transaction_id'.tr, style: cairoRegular),
                  Text(transactions.id!, style: cairoRegular),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('package_name'.tr, style: cairoRegular),
                  Text(transactions.package?.packageName ?? '', style: cairoRegular),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('time'.tr, style: cairoRegular),
                  Text(DateConverterHelper.utcToDate(transactions.createdAt!), style: cairoRegular),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('validity'.tr, style: cairoRegular),
                  Text('${transactions.validity} ${'days'.tr}', style: cairoRegular),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('amount'.tr, style: cairoRegular),
                  Text(PriceConverterHelper.convertPrice(transactions.paidAmount), style: cairoRegular),
                ]),
                const SizedBox(height: 40),

              ]),
            ),
          ),
        ),

      ]),
    );
  }
}
