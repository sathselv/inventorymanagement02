import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_inventory_management/model/sales_details_model.dart';

import 'firebase/sales_details_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Inventory Management - Cart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, Object> itemDetailsMap = {};
  List<Map<String, Object>> itemDetailsList = [];
  Future<List<Map<String, Object>>> salesDetailsFuture = getList();
  int _itemQuantity;
  double _itemPrice;
  String _itemName;
  double _totalPrice = 0.0;
  String _itemNameInitial = "";
  String _itemPriceInitial = "";
  String _itemQuantityInitial = "";
  double _totalAmount = 0;
  double _netAmount = 0;
  double _gst = 0.0;

  Widget purchaseDetails(BuildContext context) {
    FocusNode _textFocus = new FocusNode();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: _itemNameInitial,
            key: Key("item-name"),
            validator: (value) {
              if (value.isEmpty) {
                return '* Enter Item Name';
              } else if(value.length<=2){
                return 'Name must be more than 2 charater';
              }
              return null;
            },
            decoration: InputDecoration(labelText: "Item Name", hintText: "Item Name"),
            keyboardType: TextInputType.text,
            onSaved: (String value) {
              if (value.isNotEmpty) {
                itemDetailsMap["itemName"] = value;
                _itemName = value;
              }
            },

          ),
          TextFormField(
            initialValue: _itemPriceInitial,
            key: Key("item-price"),
            validator: (value) {
              if (value.isEmpty) {
                return '* Enter Item Price';
              }
              if(double.parse(value)>999999||double.parse(value)<=0){
                return 'Item Price must between 1 to 1000';
              }
              return null;
            },
            decoration: InputDecoration(labelText: "Item Price", hintText: "Item Price", prefixText: '₹'),
            textDirection: TextDirection.rtl,
            keyboardType: TextInputType.numberWithOptions(),
            onSaved: (String value) {
              if (value.isNotEmpty) {
                itemDetailsMap["itemPrice"] = double.parse(value);
                _itemPrice = double.parse(value);
              } else {
                itemDetailsMap["itemPrice"] = 0;
                _itemPrice = 0;
              }
            },
            onChanged: (String value) {
              if (value.isNotEmpty) {
                _itemPrice = double.parse(value);
                getTotalPrice(_itemQuantity, _itemPrice);
              }
            },
          ),
          TextFormField(
            initialValue: _itemQuantityInitial,
            key: Key("item-quantity"),
            validator: (value) {
              if (value.isEmpty) {
                return '* Enter Item Quantity';
              }
              if(int.parse(value)>10||int.parse(value)<=0){
                return 'Item Quantity must between 1 to 10';
              }
              return null;
            },
            decoration: InputDecoration(labelText: "Item Quantity", hintText: "Item Quantity"),
            keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
            inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
            textDirection: TextDirection.rtl,
            onChanged: (String value) {
              if (value.isNotEmpty) {
                _itemQuantity = int.parse(value);
                getTotalPrice(_itemQuantity, _itemPrice);
              }
            },
            onSaved: (String value) {
              if (value.isNotEmpty) {
                itemDetailsMap["itemQuantity"] = double.parse(value);
                _itemQuantity = int.parse(value);
              } else {
                itemDetailsMap["itemQuantity"] = 0;
                _itemQuantity = 0;
              }
            },
          ),
        ],
      ),
    );
  }

  void getTotalPrice(int itemQuantity, double itemPrice) {
    setState(() {
      if (itemPrice != null && itemQuantity != null) {
        _totalPrice = itemPrice * itemQuantity;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: salesDetailsFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<Map<String, Object>> salesDetailsList = snapshot.data;
            int length = 0;
            if (salesDetailsList != null && salesDetailsList.length != null) {
              length = salesDetailsList.length;
            }
            double screenWidth = MediaQuery.of(context).size.width;
            double screenHeight = MediaQuery.of(context).size.height;
            if (length == 0) {
              return Container(
                padding: EdgeInsets.only(right: 90, bottom: 200),
                child: Center(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Add Items To Purchase",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              );
            }
            return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[SizedBox(height: 10),
                  Text("Cart - Added Items", style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Expanded(child: new ListView.builder(
                    itemCount: salesDetailsList == null ? 0 : length,
                    itemBuilder: (BuildContext context, int index) {
                      return new Card(
                        child: Column( children:<Widget>[
                        new ListTile(
                          leading: CircleAvatar(),
                          title: Text(salesDetailsList[index]["itemName"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          subtitle: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: <Widget>[
                                Text('₹'+salesDetailsList[index]["totalPrice"].toString(), style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                                Spacer(),
                                Text(salesDetailsList[index]["itemQuantity"].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                               Text("  Qty : ",),
                                Spacer(),
                                Text(salesDetailsList[index]["itemPrice"].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text("Price : ₹"),
                              ]),
                          onTap: () {
                            _doEditItems(context, salesDetailsList[index], index);
                          },
                          onLongPress: () {
                            removeUnnecessaryItem(context, index, salesDetailsList);
                          },
                        ),
                      ]),
                      );
                    },
                  )),
                  Card(
                    child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Row(textDirection: TextDirection.rtl,
                                    children: <Widget>[
                                      Text("₹"+_totalAmount.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                      Flexible(fit: FlexFit.tight, child: SizedBox()),
                                      Text("Total Amount : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))],
                                  ),
                                   SizedBox(height: 10),
                                   Row(textDirection: TextDirection.rtl,
                                     children: <Widget>[
                                      Text("₹"+_gst.toString(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                      Flexible(fit: FlexFit.tight, child: SizedBox()),
                                      Text("GST(5 %) : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                  ]),
                                   SizedBox(height: 20),
                                   Row(textDirection: TextDirection.rtl,
                                      children: <Widget>[
                                        Text("₹"+_netAmount.toString(), style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                                        Flexible(fit: FlexFit.tight, child: SizedBox()),
                                        SizedBox(width: 10,),
                                        Text("Net Amount : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ]),
                                    SizedBox(height: 10)
                                ],
                            )
            ),
                  ),
                  SizedBox(height: 10),
                    Container(
                        width: 180.0,
                        height: 50.0,
                        child : new RaisedButton(
                            child: new Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,letterSpacing: 2)),
                            color: Colors.blue,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.blueAccent)
                      ),
                      onPressed: () {
                        getCheckedOut();
                        setState(() {
                          salesDetailsFuture = getList();
                        });
                      })),
                  SizedBox(height: 20)
                ]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _totalPrice = 0.0;
            _itemNameInitial = "";
            _itemPriceInitial = "";
            _itemQuantityInitial = "";
          });
          getAddItemDialog(context, 0, false);
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, Object>>> getUpdatedItemFutureList(String itemName,
      double itemPrice, int itemQuantity, int index, bool useIndex) async {
    Map<String, Object> updateItemMap = {};
    updateItemMap["itemName"] = itemName;
    updateItemMap["itemPrice"] = itemPrice;
    updateItemMap["itemQuantity"] = itemQuantity;
    updateItemMap["totalPrice"] = itemQuantity * itemPrice;
    if (itemName != null && itemName != "" && !useIndex) {
      itemDetailsList.add(updateItemMap);
    } else if (itemName != null && itemName != "" && useIndex) {
      itemDetailsList[index] = updateItemMap;
    }
    return itemDetailsList;
  }

  static Future<List<Map<String, Object>>> getList() async {
    List<Map<String, Object>> list = [];
    return list;
  }

  void getAddItemDialog(BuildContext context, int index, bool useIndex) {
    showDialog(context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Item Details"),
              content: Container(
                child: Column(children: <Widget>[purchaseDetails(context)],mainAxisSize: MainAxisSize.min,),
              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(useIndex?"Save":'Add Item'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Navigator.of(context).pop();
                        _formKey.currentState.save();
                        setState(() {
                          salesDetailsFuture = getUpdatedItemFutureList(_itemName, _itemPrice, _itemQuantity, index, useIndex);
                          _totalAmount = getTotalAmount();
                          _gst = (_totalAmount*5)/100;
                          _netAmount = _totalAmount+_gst;
                        });
                      }
                    }),
                new FlatButton(
                    child: new Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            ));
  }

  void _doEditItems(
      BuildContext context, Map<String, Object> salesDetailsMap, int index) {
    setState(() {
      _itemNameInitial = salesDetailsMap["itemName"];
      _itemPriceInitial = salesDetailsMap["itemPrice"].toString();
      _itemQuantityInitial = salesDetailsMap["itemQuantity"].toString();
    });
    getAddItemDialog(context, index, true);
  }

  void removeUnnecessaryItem(BuildContext context, int index,
      List<Map<String, Object>> salesDetailsList) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Confirm"),
              content: Text("Are you want to remove this item?"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("Accept"),
                  onPressed: () {
                    setState(() {
                      salesDetailsFuture = getRemovedList(salesDetailsList, index);
                      _totalAmount = getTotalAmount();
                      _gst = (_totalAmount*5)/100;
                      _netAmount = _totalAmount+_gst;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<List<Map<String, Object>>> getRemovedList(List<Map<String, Object>> salesDetailsList, int index) async {
    itemDetailsList.removeAt(index);
    return itemDetailsList;
  }

  double getTotalAmount() {
    double total = 0.0;
    if(itemDetailsList!=null){
      for (var itemMap in itemDetailsList) {
        total = total+itemMap['totalPrice'];
      }
      return total;
    }
    return total;
  }

  getCheckedOut() {
    SalesDetails salesDetails = new SalesDetails();
    SalesDetails data=salesDetails.setValuesFromMap(itemDetailsList, _netAmount, "sathish");
    SalesDetailsApi().insert(data);
  }
}
