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
  Future<void> addImageUrl(String url, String userId) async {
    try {
      List<String> images = await getImages(userId);
      images.add(url);
      await _db.collection('users').doc(userId).update({
        'images': images,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<List<String>> getImages(String userId) async {
    try {
      var data = await _db.collection('users').doc(userId).get();

      List<String> images = data['images'].cast<String>();

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
