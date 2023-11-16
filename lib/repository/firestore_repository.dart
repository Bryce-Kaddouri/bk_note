import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_repository.dart';

class FirestoreRepository {
  // private constructor
  FirestoreRepository._();

  // create instance of FirestoreRepository
  static FirestoreRepository instance = FirestoreRepository._();

  // create instance of FirebaseFirestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseFirestore get db => _db;

  // method to add the url of the image to the firestore
  Future<void> addImageUrl(
      String url, String userId, String idImage, List<String> keywords) async {
    try {
      List<dynamic> images = [];
      var data = await getAllImagesSync(userId);
      print('data');
      print(data);
      if (data != null) {
        images = data;
      }
      images.add({
        'url': url,
        'id': idImage,
        'keywords': keywords,
      });
      print('images');
      print(images);

      await _db.collection('users').doc(userId).update({
        'images': images,
      });
    } catch (e) {
      throw e;
    }
  }

  Future getAllImagesSync(String userId) async {
    try {
      var data = await _db.collection('users').doc(userId).get();
      return data.get('images');
    } catch (e) {
      throw e;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getImages(String userId) {
    try {
      var data = _db.collection('users').doc(userId).snapshots();

      return data;
    } catch (e) {
      throw e;
    }
  }

  Future<void> initImages(String userId) async {
    try {
      await _db.collection('users').doc(userId).set({
        'images': [],
      });
    } catch (e) {
      throw e;
    }
  }
}
