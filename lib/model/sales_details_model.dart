import 'package:cloud_firestore/cloud_firestore.dart';

class SalesDetails {
  String documentId;
  String userId;
  DateTime saleDate;
  List<SalesData> salesData;

  SalesDetails({this.documentId,this.userId,this.saleDate,this.salesData});

  SalesDetails setValues(Map<String, Object> data) {
    this.userId = data['userId'];
    this.saleDate = data['saleDate'];
    this.salesData = data['salesData'];
    return this;
  }
  SalesDetails setValuesFromMap(List<Map<String, Object>> itemDetailsList, double netAmount, String userId) {
    this.documentId = getDocumentId();
    this.saleDate = new DateTime.now();
    this.userId = userId;
    this.saleDate = new DateTime.now();
    List<SalesData> salesDataList = [];;
    for (var itemMap in itemDetailsList) {
      SalesData salesData = new SalesData();
      salesData.itemName = itemMap["itemName"].toString();
      salesData.sellingPricePerItem = itemMap["itemPrice"];
      salesData.quantitySold = itemMap["itemQuantity"];
      salesData.totalSellingPrice = itemMap["totalPrice"];
      salesData.netAmount = netAmount;
      salesDataList.add(salesData);
    }
    this.salesData = salesDataList;
    return this;
  }

  SalesDetails.fromMap(Map snapshot, String documentId)
      : documentId = documentId ?? '',
        userId = snapshot['userId'] ?? '',
        saleDate = getDate(snapshot['saleDate']) ?? null,
        salesData = SalesData().getList(snapshot['salesData']) ?? null;

  List<SalesDetails> fromList(var doc){
    List<SalesDetails> salesDetailsList = [];
    for (var salesDetails in doc) {
      salesDetailsList.add(SalesDetails.fromMap(salesDetails.data, salesDetails.documentID));
    }
    return salesDetailsList;
  }

  toJson() {
    return {
      "userId": userId,
      "saleDate": saleDate,
      "salesData": SalesData().toJson(salesData),
    };
  }

  static DateTime getDate(Timestamp timestamp) {
    return timestamp.toDate();
  }

  String getDocumentId() {
    var currentDate = new DateTime.now();
    String documentId = currentDate.day.toString()+currentDate.month.toString()+currentDate.year.toString();
    return documentId;
  }
}

class SalesData {
  String itemId;
  String itemName;
  double costPricePerItem;
  double sellingPricePerItem;
  int quantitySold;
  double totalCostPrice;
  double totalSellingPrice;
  bool isProfit;
  double netAmount;

  List<SalesData> getList(var salesData) {
    List<SalesData> salesDetailsList = [];
    for (Map<String, Object> data in salesData) {
      SalesData salesData = SalesData();
      salesData.itemId = data['itemId'];
      salesData.itemName = data['itemName'];
      salesData.costPricePerItem = double.parse(data['costPricePerItem'].toString());
      salesData.sellingPricePerItem = double.parse(data['sellingPricePerItem'].toString());
      salesData.quantitySold = data['quantitySold'];
      salesData.totalCostPrice = double.parse(data['totalCostPrice'].toString());
      salesData.totalSellingPrice = double.parse(data['totalSellingPrice'].toString());
      salesData.isProfit = data['isProfit'];
      salesData.netAmount = double.parse(data['netAmount'].toString());
      salesDetailsList.add(salesData);
    }
    return salesDetailsList;
  }

  toJson(List<SalesData> salesDataList) {
    return salesDataList.map((salesData) {
      return {
        "itemId": salesData.itemId,
        "itemName": salesData.itemName,
        "costPricePerItem": salesData.costPricePerItem,
        "sellingPricePerItem": salesData.sellingPricePerItem,
        "quantitySold": salesData.quantitySold,
        "totalCostPrice": salesData.totalCostPrice,
        "totalSellingPrice": salesData.totalSellingPrice,
        "isProfit": salesData.isProfit,
        "netAmount": salesData.netAmount,
      };
    }).toList();
  }
}
