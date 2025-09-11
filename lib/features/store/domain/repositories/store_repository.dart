// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/vat_tax_model.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/attr.dart';
import 'package:sixam_mart_store/features/store/domain/models/attribute_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/band_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/pending_item_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/review_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/suitable_tag_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/unit_model.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/store/domain/repositories/store_repository_interface.dart';

class StoreRepository implements StoreRepositoryInterface {
  final ApiClient apiClient;
  StoreRepository({required this.apiClient});

  @override
  Future<ItemModel?> getItemList(
      {required String offset,
      required String type,
      required String search,
      int? categoryId}) async {
    ItemModel? itemModel;
    Response response = await apiClient.getData(
        '${AppConstants.itemListUri}?offset=$offset&limit=10&type=$type&search=$search${categoryId != null ? '&category_id=$categoryId' : 0}');
    if (response.statusCode == 200) {
      itemModel = ItemModel.fromJson(response.body);
    }
    return itemModel;
  }

  @override
  Future<ItemModel?> getStockItemList(String offset) async {
    ItemModel? itemModel;
    Response response = await apiClient
        .getData('${AppConstants.stockLimitItemsUri}?offset=$offset&limit=10');
    if (response.statusCode == 200) {
      itemModel = ItemModel.fromJson(response.body);
    }
    return itemModel;
  }

  @override
  Future<PendingItemModel?> getPendingItemList(
      String offset, String type) async {
    PendingItemModel? pendingItemModel;
    Response response = await apiClient.getData(
        '${AppConstants.pendingItemListUri}?status=$type&offset=$offset&limit=20');
    if (response.statusCode == 200) {
      pendingItemModel = PendingItemModel.fromJson(response.body);
    }
    return pendingItemModel;
  }

  @override
  Future<Item?> getPendingItemDetails(int itemId) async {
    Item? pendingItem;
    Response response = await apiClient
        .getData('${AppConstants.pendingItemDetailsUri}/$itemId');
    if (response.statusCode == 200) {
      pendingItem = Item.fromJson(response.body);
    }
    return pendingItem;
  }

  @override
  Future<Item?> get(int? id) async {
    Item? item;
    Response response =
        await apiClient.getData('${AppConstants.itemDetailsUri}/$id');
    if (response.statusCode == 200) {
      item = Item.fromJson(response.body);
    }
    return item;
  }

  @override
  Future<List<AttributeModel>?> getAttributeList(Item? item) async {
    List<AttributeModel>? attributeList;
    Response response = await apiClient.getData(AppConstants.attributeUri);
    if (response.statusCode == 200) {
      attributeList = [];
      response.body.forEach((attribute) {
        if (item != null) {
          bool active = item.attributes!.contains(Attr.fromJson(attribute).id);
          List<String> options = [];
          if (active) {
            options.addAll(item
                .choiceOptions![
                    item.attributes!.indexOf(Attr.fromJson(attribute).id)]
                .options!);
          }
          attributeList!.add(AttributeModel(
            attribute: Attr.fromJson(attribute),
            active: item.attributes!.contains(Attr.fromJson(attribute).id),
            controller: TextEditingController(),
            variants: options,
          ));
        } else {
          attributeList!.add(AttributeModel(
            attribute: Attr.fromJson(attribute),
            active: false,
            controller: TextEditingController(),
            variants: [],
          ));
        }
      });
    }
    return attributeList;
  }

  @override
  Future<bool> updateStoreBasicInfo(Store store, XFile? logo, XFile? cover,
      List<Translation> translation, XFile? metaImage) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put',
      'translations': jsonEncode(translation),
      'contact_number': store.phone ?? '',
    });
    Response response = await apiClient
        .postMultipartData(AppConstants.vendorBasicInfoUpdateUri, fields, [
      MultipartBody('logo', logo),
      MultipartBody('cover_photo', cover),
      MultipartBody('meta_image', metaImage)
    ]);
    return (response.statusCode == 200);
  }

  @override
  Future<bool> updateStore(
      Store store, String min, String max, String type) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put',
      'schedule_order': store.scheduleOrder! ? '1' : '0',
      'minimum_order': store.minimumOrder.toString(),
      'delivery': store.delivery! ? '1' : '0',
      'take_away': store.takeAway! ? '1' : '0',
      'gst_status': store.gstStatus! ? '1' : '0',
      'gst': store.gstCode!,
      'minimum_delivery_charge': store.minimumShippingCharge.toString(),
      'per_km_delivery_charge': store.perKmShippingCharge.toString(),
      'veg': store.veg.toString(),
      'non_veg': store.nonVeg.toString(),
      'order_place_to_schedule_interval':
          store.orderPlaceToScheduleInterval.toString(),
      'minimum_delivery_time': min,
      'maximum_delivery_time': max,
      'delivery_time_type': type,
      'prescription_order': store.prescriptionStatus! ? '1' : '0',
      'cutlery': store.cutlery! ? '1' : '0',
      'free_delivery': store.freeDelivery! ? '1' : '0',
      'extra_packaging_status': store.extraPackagingStatus! ? '1' : '0',
      'extra_packaging_amount': store.extraPackagingAmount!.toString(),
      'minimum_stock_for_warning': store.minimumStockForWarning.toString(),
    });
    if (store.maximumShippingCharge != null) {
      fields.addAll(
          {'maximum_delivery_charge': store.maximumShippingCharge.toString()});
    }
    Response response =
        await apiClient.postData(AppConstants.vendorUpdateUri, fields);
    return (response.statusCode == 200);
  }

  @override
  Future<Response> addItem(
      Item item,
      XFile? image,
      List<XFile> images,
      List<String> savedImages,
      Map<String, String> attributes,
      bool isAdd,
      String tags,
      String nutrition,
      String allergicIngredients,
      String genericName) async {
    Map<String, String> fields = {};

    // ===== helpers / safe reads =====
    final profileCtrl = Get.find<ProfileController>();
    final profileModel = profileCtrl.profileModel;
    final hasStores = profileModel != null &&
        profileModel.stores != null &&
        profileModel.stores!.isNotEmpty;
    final firstStore = hasStores ? profileModel.stores![0] : null;
    final moduleType = (firstStore?.module?.moduleType) ?? '';

    final splashCtrl = Get.find<SplashController>();
    final moduleConfig = splashCtrl.configModel?.moduleConfig?.module;

    String safeCategoryId = '0';
    if (item.categoryIds != null &&
        item.categoryIds!.isNotEmpty &&
        item.categoryIds![0].id != null) {
      safeCategoryId = item.categoryIds![0].id!;
    }

    // translations safe json
    final translationsJson = jsonEncode(item.translations ?? []);

    // safe numeric/string conversions
    final priceStr = item.price?.toString() ?? '0';
    final discountStr = item.discount?.toString() ?? '0';
    final vegStr = item.veg?.toString() ?? '0';
    final maxCartQty = item.maxOrderQuantity?.toString() ?? '0';

    // fields common
    fields.addAll(<String, String>{
      'price': priceStr,
      'discount': discountStr,
      'veg': vegStr,
      'discount_type': item.discountType ?? '',
      'category_id': safeCategoryId,
      'translations': translationsJson,
      'tags': tags,
      'maximum_cart_quantity': maxCartQty,
    });

    // module-specific fields (safe checks)
    if (moduleType == 'grocery' || moduleType == 'food') {
      fields.addAll(<String, String>{
        'nutritions': nutrition,
        'allergies': allergicIngredients
      });
    }

    if (moduleType == 'pharmacy') {
      fields.addAll(<String, String>{'generic_name': genericName});
      if (item.conditionId != null) {
        fields['condition_id'] = item.conditionId.toString();
      }
    }

    if (moduleConfig?.stock ?? false) {
      fields['current_stock'] = (item.stock ?? 0).toString();
    }

    if (moduleType == 'pharmacy') {
      fields['is_prescription_required'] =
          (item.isPrescriptionRequired ?? 0).toString();
      fields['basic'] = (item.isBasicMedicine ?? 0).toString();
    }

    if (moduleType == 'ecommerce' && item.brandId != null) {
      fields['brand_id'] = item.brandId.toString();
    }

    if ((moduleType == 'grocery' || moduleType == 'food') &&
        item.isHalal != null) {
      fields['is_halal'] = item.isHalal.toString();
    }

    if (moduleConfig?.unit ?? false) {
      if ((item.unitType ?? '').isNotEmpty) {
        fields['unit'] = item.unitType!;
      }
    }

    if (moduleConfig?.itemAvailableTime ?? false) {
      if ((item.availableTimeStarts ?? '').isNotEmpty) {
        fields['available_time_starts'] = item.availableTimeStarts!;
      }
      if ((item.availableTimeEnds ?? '').isNotEmpty) {
        fields['available_time_ends'] = item.availableTimeEnds!;
      }
    }

    // addon ids (safe)
    String addon = '';
    if (item.addOns != null && item.addOns!.isNotEmpty) {
      for (int index = 0; index < item.addOns!.length; index++) {
        final id = item.addOns![index].id;
        if (id != null) {
          addon = '$addon${index == 0 ? id : ',$id'}';
        }
      }
    }
    fields['addon_ids'] = addon;

    // sub category
    if (item.categoryIds != null && item.categoryIds!.length > 1) {
      final subId = item.categoryIds![1].id;
      if (subId != null) fields['sub_category_id'] = subId;
    }

    // update case
    if (!isAdd) {
      fields.addAll(<String, String>{
        '_method': 'put',
        'id': (item.itemId != null)
            ? item.itemId.toString()
            : (item.id?.toString() ?? '0'),
        'images': jsonEncode(savedImages),
      });
    }

    // variations / attributes
    if (splashCtrl.getStoreModuleConfig().newVariation! &&
        (item.foodVariations != null && item.foodVariations!.isNotEmpty)) {
      fields['options'] = jsonEncode(item.foodVariations);
    } else if (!(splashCtrl.getStoreModuleConfig().newVariation!) &&
        attributes.isNotEmpty) {
      fields.addAll(attributes);
    }

    // tax ids
    if (splashCtrl.configModel?.systemTaxType == 'product_wise') {
      fields['tax_ids'] = jsonEncode(item.taxVatIds ?? []);
    }

    // prepare multipart bodies (only include non-null files)
    List<MultipartBody> images0 = [];
    if (image != null) images0.add(MultipartBody('image', image));
    for (int index = 0; index < images.length; index++) {
      if (images[index] != null)
        images0.add(MultipartBody('item_images[]', images[index]));
    }

    // removed image keys (safe)
    final storeCtrl = Get.find<StoreController>();
    fields['removedImageKeys'] = jsonEncode(storeCtrl.removeImageList);

    if (!isAdd) {
      fields['temp_product'] = '1';
    }

    // finally call API (don't change handleError behavior)
    Response response = await apiClient.postMultipartData(
        isAdd ? AppConstants.addItemUri : AppConstants.updateItemUri,
        fields,
        images0,
        handleError: false);
    return response;
  }

  @override
  Future<bool> deleteItem(int? itemID, bool pendingItem) async {
    Response response = await apiClient.deleteData(
        '${AppConstants.deleteItemUri}?id=$itemID${pendingItem ? '&temp_product=1' : ''}');
    return (response.statusCode == 200);
  }

  @override
  Future<List<ReviewModel>?> getStoreReviewList(
      int? storeID, String? searchText) async {
    List<ReviewModel>? storeReviewList;
    Response response = await apiClient.getData(
        '${AppConstants.vendorReviewUri}?store_id=$storeID&search=$searchText');
    if (response.statusCode == 200) {
      storeReviewList = [];
      response.body.forEach(
          (review) => storeReviewList!.add(ReviewModel.fromJson(review)));
    }
    return storeReviewList;
  }

  @override
  Future<List<ReviewModel>?> getItemReviewList(int? itemID) async {
    List<ReviewModel>? itemReviewList;
    Response response =
        await apiClient.getData('${AppConstants.itemReviewUri}/$itemID');
    if (response.statusCode == 200) {
      itemReviewList = [];
      response.body['reviews'].forEach((review) {
        itemReviewList!.add(ReviewModel.fromJson(review));
      });
    }
    return itemReviewList;
  }

  @override
  Future<bool> updateItemStatus(int? itemID, int status) async {
    Response response = await apiClient.getData(
        '${AppConstants.updateItemStatusUri}?id=$itemID&status=$status');
    return (response.statusCode == 200);
  }

  @override
  Future<int?> add(Schedules schedule) async {
    int? scheduleID;
    Response response =
        await apiClient.postData(AppConstants.addSchedule, schedule.toJson());
    if (response.statusCode == 200) {
      scheduleID = int.parse(response.body['id'].toString());
    }
    return scheduleID;
  }

  @override
  Future<Response> stockUpdate(Map<String, String> data) async {
    return await apiClient.postData(AppConstants.itemStockUpdateUri, data);
  }

  @override
  Future<bool> delete(int? id) async {
    Response response =
        await apiClient.deleteData('${AppConstants.deleteSchedule}$id');
    return (response.statusCode == 200);
  }

  @override
  Future<List<UnitModel>?> getUnitList() async {
    List<UnitModel>? unitList;
    Response response = await apiClient.getData(AppConstants.unitListUri);
    if (response.statusCode == 200) {
      unitList = [];
      response.body.forEach((unit) => unitList!.add(UnitModel.fromJson(unit)));
    }
    return unitList;
  }

  @override
  Future<bool> updateRecommendedProductStatus(
      int? productID, int status) async {
    Response response = await apiClient.getData(
        '${AppConstants.updateProductRecommendedUri}?id=$productID&status=$status');
    return (response.statusCode == 200);
  }

  @override
  Future<bool> updateOrganicProductStatus(int? productID, int status) async {
    Response response = await apiClient.getData(
        '${AppConstants.updateProductOrganicUri}?id=$productID&organic=$status');
    return (response.statusCode == 200);
  }

  @override
  Future<bool> updateAnnouncement(int status, String announcement) async {
    Map<String, String> fields = {
      'announcement_status': status.toString(),
      'announcement_message': announcement,
      '_method': 'put'
    };
    Response response =
        await apiClient.postData(AppConstants.announcementUri, fields);
    return (response.statusCode == 200);
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future<List<BrandModel>?> getBrandList() async {
    List<BrandModel>? brands;
    Response response = await apiClient.getData(AppConstants.getBrandsUri);
    if (response.statusCode == 200) {
      brands = [];
      response.body!.forEach((brand) {
        brands!.add(BrandModel.fromJson(brand));
      });
    }
    return brands;
  }

  @override
  Future<List<SuitableTagModel>?> getSuitableTagList() async {
    List<SuitableTagModel>? suitableTagList;
    Response response = await apiClient.getData(AppConstants.suitableTagUri);
    if (response.statusCode == 200) {
      suitableTagList = [];
      response.body.forEach((tag) {
        suitableTagList!.add(SuitableTagModel.fromJson(tag));
      });
    }
    return suitableTagList;
  }

  @override
  Future<bool> updateReply(int reviewID, String reply) async {
    Map<String, String> fields = {
      'id': reviewID.toString(),
      'reply': reply,
      '_method': 'put'
    };
    Response response =
        await apiClient.postData(AppConstants.updateReplyUri, fields);
    return (response.statusCode == 200);
  }

  @override
  Future<List<String?>?> getNutritionSuggestionList() async {
    List<String?>? nutritionSuggestionList;
    Response response =
        await apiClient.getData(AppConstants.getNutritionSuggestionUri);
    if (response.statusCode == 200) {
      nutritionSuggestionList = [];
      response.body
          .forEach((nutrition) => nutritionSuggestionList?.add(nutrition));
    }
    return nutritionSuggestionList;
  }

  @override
  Future<List<String?>?> getAllergicIngredientsSuggestionList() async {
    List<String?>? allergicIngredientsSuggestionList;
    Response response = await apiClient
        .getData(AppConstants.getAllergicIngredientsSuggestionUri);
    if (response.statusCode == 200) {
      allergicIngredientsSuggestionList = [];
      response.body.forEach((allergicIngredients) =>
          allergicIngredientsSuggestionList?.add(allergicIngredients));
    }
    return allergicIngredientsSuggestionList;
  }

  @override
  Future<List<String?>?> getGenericNameSuggestionList() async {
    List<String?>? genericNameSuggestionList;
    Response response =
        await apiClient.getData(AppConstants.getGenericNameSuggestionUri);
    if (response.statusCode == 200) {
      genericNameSuggestionList = [];
      response.body.forEach(
          (genericName) => genericNameSuggestionList?.add(genericName));
    }
    return genericNameSuggestionList;
  }

  @override
  Future<List<VatTaxModel>?> getVatTaxList() async {
    List<VatTaxModel>? vatTaxList;
    Response response = await apiClient.getData(AppConstants.vatTaxListUri);
    if (response.statusCode == 200) {
      vatTaxList = [];
      response.body
          .forEach((vatTax) => vatTaxList!.add(VatTaxModel.fromJson(vatTax)));
    }
    return vatTaxList;
  }
}
