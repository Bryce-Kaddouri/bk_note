import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../repository/firestore_repository.dart';
import '../repository/storage_repository.dart';

class StorageProvider with ChangeNotifier {
  double _progress = 0;
  double get progress => _progress;

  Stream<TaskSnapshot> uploadImage(File file, String userId) {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'picked-file-path': file.path,
        },
      );
      Reference reference = StorageRepository.instance.storage.ref().child(
            '$userId/$fileName.jpg',
          );
      UploadTask uploadTask = reference.putFile(file, metadata);
      return uploadTask.snapshotEvents;
    } catch (e) {
      throw e;
    }
  }

  void setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void clearProgress() {
    _progress = 0;
    notifyListeners();
  }
}
