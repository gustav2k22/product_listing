import 'dart:convert';

import 'package:dummy_product_app/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  // var favoriteIds = <int>[].obs;
  var currentPage = 0.obs;
  var hasMore = true.obs;
  final int limit = 30;

@override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      currentPage.value = 0;
      products.clear();
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    isLoading.value = true;

    try {
      final skip = currentPage.value * limit;
      final response = await http.get 
      (Uri.parse('https://dummyjson.com/products?limit=$limit&skip=$skip'),
      );
      if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Product> newProducts = (data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
      debugPrint(
          'Fetched products: ${newProducts.map((product) => product.title).join(', ')}');
      debugPrint('Product Info: $data');

      products.addAll(newProducts);
      currentPage.value++;

      if (products.length >= data ['total']) {
      hasMore.value = false;
      }
      }
    } catch (e) {
    Get.snackbar('Error', 'Failed to Load Products',
    snackPosition: SnackPosition.BOTTOM);
    } finally {
    isLoading.value = false;
    }
  }

}