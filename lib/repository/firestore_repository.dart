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
  Future<void> addImageUrl(String url, String userId, String idImage) async {
    try {
      List<Map<String, dynamic>> images = await getImages(userId);
      images.add({
        'url': url,
        'id': idImage,
      });
      await _db.collection('users').doc(userId).update({
        'images': images,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getImages(String userId) async {
    try {
      var data = await _db.collection('users').doc(userId).get();

      List<Map<String, dynamic>> images =
          data['images'].cast<Map<String, dynamic>>();

      return images;
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
