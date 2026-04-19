import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cash_flow_controller.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;
  bool isSearchVisible = false;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(() {
      if (selectedIndex == 1) {
        Get.find<CashFlowController>()
            .setSearchQuery(searchTextController.text);
      }
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    selectedIndex = index;

    if (isSearchVisible) {
      isSearchVisible = false;
      searchTextController.clear();
      Get.find<CashFlowController>().setSearchQuery('');
    }
    update();
  }

  void toggleSearch() {
    isSearchVisible = !isSearchVisible;
    if (!isSearchVisible) {
      searchTextController.clear();
      Get.find<CashFlowController>().setSearchQuery('');
    }
    update();
  }

  String getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user.email!.split('@')[0];
    }
    return 'User';
  }

  String? getUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }
}
