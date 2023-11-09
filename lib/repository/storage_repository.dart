// import firebase storgae
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_repository.dart';

class StorageRepository {
  // private constructor
  StorageRepository._();

  // create instance of StorageRepository
  static StorageRepository instance = StorageRepository._();

  // create instance of FirebaseStorage
  final FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseStorage get storage => _storage;

  // instance of AuthRepository
  final AuthRepository _authRepository = AuthRepository.instance;

  // method to upload image to firebase storage
  Stream<TaskSnapshot> uploadImage(File file) {
    try {
      String userId = _authRepository.auth.currentUser!.uid;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = _storage.ref().child('images/$userId/$fileName');
      UploadTask uploadTask = reference.putFile(file);
      return uploadTask.snapshotEvents;
    } catch (e) {
      throw e;
    }
  }
}
