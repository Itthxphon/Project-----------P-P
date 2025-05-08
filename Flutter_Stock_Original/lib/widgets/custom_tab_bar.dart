import 'package:Nippostock/config/constant.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTab;
  final bool isBottomIndicator;
  final List<int> countStatus;

  const CustomTabBar({
    Key? key,
    required this.icons,
    required this.selectedIndex,
    required this.onTab,
    this.isBottomIndicator = false,
    required this.countStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 3),
          child: Container(
            decoration: const BoxDecoration(
              //color: kPrimaryColor,
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                border: isBottomIndicator
                    ? const Border(
                        bottom: BorderSide(
                          color: kPrimaryColor,
                          width: 3.0,
                        ),
                      )
                    : const Border(
                        top: BorderSide(
                          color: kPrimaryColor,
                          width: 3.0,
                        ),
                      ),
              ),
              tabs: icons
                  .asMap()
                  .map(
                    (i, e) => MapEntry(
                      i,
                      Stack(
                        children: [
                          Tab(
                            icon: Icon(
                              e,
                              color: i == selectedIndex
                                  ? kPrimaryColor
                                  : Colors.grey,
                              size: 30.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, bottom: 3),
                            child: i == 0
                                ? const SizedBox.shrink()
                                : countStatus[i] != 0
                                    ? CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.red,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            countStatus[i] >= 100
                                                ? '99+'
                                                : countStatus[i].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                          )
                        ],
                      ),
                    ),
                  )
                  .values
                  .toList(),
              onTap: onTab,
            ),
          )),
    );
  }
}
