import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void showBottomMenuSheet(
    BuildContext context,
    List options, {
      double? height,
    }) {
  showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPopupSurface(
        child: Container(
          height: height ?? 560,
          width: double.infinity,
          child: Material(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 30),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true)
                                  .pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: options
                          .map<Widget>(
                            (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: e["fn"],
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 28, 20, 28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 15,
                                    color:
                                    Colors.black.withOpacity(0.06),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(left: 18),
                                    child: Text(
                                      e["title"],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: e["color"],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    e["icon"],
                                    color: e["color"] ?? Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
}