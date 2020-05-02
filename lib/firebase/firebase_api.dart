import 'package:cloud_firestore/cloud_firestore.dart';

class Api{
  final Firestore _db = Firestore.instance;
  final String path;
  CollectionReference ref;

  Api( this.path ) {
    ref = _db.collection(path);
  }

  Future<QuerySnapshot> getDataCollection() {
    return ref.getDocuments() ;
  }
  Stream<QuerySnapshot> streamDataCollection() {
    return ref.snapshots() ;
  }
  Future<DocumentSnapshot> getDocumentById(String id) {
    return ref.document(id).get();
  }

  Future<List<DocumentSnapshot>>getDocumentByValue(String column,Object value) {
    return ref.where(column, isEqualTo:value).getDocuments().then((value){
      return value.documents;
    });
  }

  Future<List<DocumentSnapshot>>getDocumentByRange(String column,Object startValue,Object endValue) {
    return ref.where(column, isGreaterThanOrEqualTo:startValue)
              .where(column, isLessThanOrEqualTo:endValue).getDocuments().then((value){
      return value.documents;
    });
  }

  Future<List<DocumentSnapshot>>getAuthDetails(String userName,String password) {
    return ref.where("userName", isEqualTo:userName).where("password", isEqualTo:password)
        .getDocuments().then((value){
      return value.documents;
    });
  }

  Future<List<DocumentSnapshot>>checkUserName(String userName) {
    return ref.where("userName", isEqualTo:userName)
        .getDocuments().then((value){
      return value.documents;
    });
  }

  Future<void> removeDocument(String id){
    return ref.document(id).delete();
  }
  Future<DocumentReference> addDocument(Map data) {
    return ref.add(data);
  }
  Future<void> updateDocument(Map data , String id) {
    return ref.document(id).updateData(data) ;
  }
}