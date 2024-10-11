import 'package:flutter/material.dart';
import 'package:tripletriocore/tripletriocore.dart';

class POSCardWidget extends StatelessWidget {
  final Product item;
  const POSCardWidget({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 5 / 3,
                      child: Stack(
                        children: [
                          item.quantity > 0
                              ? Positioned(
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    width: 10,
                                    height: 10,
                                  ),
                                )
                              : Container(),
                          Placeholder(
                              // color: Colors.transparent,
                              // child: Container(
                              //   color: Colors.grey.withOpacity(0.5),
                              // )),
                               color: Colors.transparent,
                            fallbackWidth: double.infinity,
                            fallbackHeight: double.infinity,
                          ),
                          Container(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.itemName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Kshs ${item.itemPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 1.0,
                    ),
                    Spacer(),
                    Text(
                      item.quantity.toString(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 23),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            'Kshs ${(item.quantity * item.itemPrice).toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
