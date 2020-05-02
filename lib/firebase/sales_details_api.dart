import 'firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/sales_details_model.dart';

class SalesDetailsApi {
  Api _api = Api('sales_details');

  SalesDetails salesDetails;

  Stream<QuerySnapshot> getAsStream() {
    return _api.streamDataCollection();
  }

  Future<SalesDetails> getById(String id) async {
    var doc = await _api.getDocumentById(id);
    return SalesDetails.fromMap(doc.data, doc.documentID);
  }

  Future<SalesDetails> getByDate(Timestamp value) async {
    var doc = await _api.getDocumentByValue("saleDate", value);
    return SalesDetails.fromMap(doc.single.data, doc.single.documentID);
  }

  Future<List<SalesDetails>> getByDateRange(
      Timestamp startValue, Timestamp endValue) async {
    var doc = await _api.getDocumentByRange("saleDate", startValue, endValue);
    return SalesDetails().fromList(doc);
  }

  Future delete(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future update(SalesDetails data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future insert(SalesDetails data) async {
    var result = await _api.addDocument(data.toJson());
    return;
  }

  Future insertList(List<SalesDetails> dataList) async {
    await dataList.forEach((data) => {_api.addDocument(data.toJson())});
    return;
  }
}
