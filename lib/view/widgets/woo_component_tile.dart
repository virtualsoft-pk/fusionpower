import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fusionpower/constant/colors.dart';
import 'package:fusionpower/controllers/kit_controller.dart';
import 'package:fusionpower/models/kit_model.dart';
import 'package:fusionpower/models/product_model.dart';
import 'package:fusionpower/models/woo_com_model.dart';
import 'package:get/get.dart';

import '../../controllers/helpers.dart';
import 'product_selection_tile.dart';

class WooComponentTile extends StatefulWidget {
  const WooComponentTile({
    Key? key,
    required this.wooCom,
    required this.index,
    required this.kitType,
    this.border = true,
    this.static = false,
  }) : super(key: key);

  final WooCom wooCom;
  final bool border, static;
  final KitType kitType;
  final int index;

  @override
  State<WooComponentTile> createState() => _WooComponentTileState();
}

class _WooComponentTileState extends State<WooComponentTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KitController>(builder: (con) {
      late final product;
      late final String title, subtitle;
      if (widget.kitType == KitType.solar) {
        switch (widget.index) {
          case 0:
            product = widget.wooCom.defaultProduct! as Panel;
            title =
                "${(wattsTokWh(product.watts * widget.wooCom.qty)).toStringAsFixed(0)}  kWh";
            subtitle = "Monthly Prod.";
            break;
          case 1:
            product = widget.wooCom.defaultProduct! as Inverter;
            title =
                "${(product.kwSize * widget.wooCom.qty).toStringAsFixed(0)} kW";
            subtitle = "Max Power";
            break;
          case 2:
            product = widget.wooCom.defaultProduct! as Battery;
            title =
                "${(product.storageSize * widget.wooCom.qty).toStringAsFixed(1)} kWh";
            subtitle = "Storage";
            break;
        }
      } else {
        switch (widget.index) {
          case 0:
            product = widget.wooCom.defaultProduct! as Inverter;
            title =
                "${(product.kwSize * widget.wooCom.qty).toStringAsFixed(1)} kW";
            subtitle = "Max Power";
            break;
          case 1:
            product = widget.wooCom.defaultProduct! as Battery;
            title =
                "${(product.storageSize * widget.wooCom.qty).toStringAsFixed(1)} kWh";
            subtitle = "Storage";
            break;
        }
      }
      return Container(
        height: widget.static ? 160 : 230,
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: widget.border
              ? Border.all(
                  color: const Color(0xFFC7C7CC),
                )
              : null,
        ),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          SizedBox(
            width: widget.static ? 84 : 80,
            height: widget.static ? 90 : 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: product.images[0]["src"],
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Positioned(
                    right: 0,
                    top: 22,
                    child: Container(
                      height: 26,
                      width: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: primaryBlue,
                      ),
                      child: Center(
                          child: Text(
                        "x${con.wooComponents[widget.index].qty}",
                        style: const TextStyle(color: Colors.white),
                      )),
                    )),
              ],
            ),
          ),
          if (con.wooComponents[widget.index].productIds.isNotEmpty &&
              !widget.static)
            GestureDetector(
              onTap: () {
                productChangeSheet(
                    context,
                    con.wooComponents[widget.index].products as List<Product>,
                    widget.index);
              },
              child: Container(
                width: 74,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: const Center(
                    child: Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                )),
              ),
            ),
          if (con.wooComponents[widget.index].productIds.isEmpty &&
              !widget.static)
            const SizedBox(
              height: 24,
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 0.38,
              fontWeight: FontWeight.w700,
              color: greyDark,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 10,
              overflow: TextOverflow.ellipsis,
              color: Color(0xFF898A8D),
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          if (!widget.static)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    con.incrementDefaultProductQuantity(widget.index);
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                        child: Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.black,
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    con.decrementDefaultProductQuantity(widget.index);
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                        child: Icon(
                      Icons.remove,
                      size: 18,
                      color: Colors.black,
                    )),
                  ),
                ),
              ],
            )
        ]),
      );
    });
  }

  Future<T?> productChangeSheet<T>(
    BuildContext context,
    final List<Product> products,
    int index,
  ) async {
    return Get.bottomSheet(Container(
      height: Get.height * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 12,
                ),
                const Text(
                  "Change Selection",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (var product in products)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProductSelectionTile(
                  product: product,
                  index: index,
                ),
              ),
          ],
        ),
      ),
    ));
  }
}
