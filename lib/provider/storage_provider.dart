import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../repository/firestore_repository.dart';
import '../repository/storage_repository.dart';

class StorageProvider with ChangeNotifier {
  double _progress = 0;
  double get progress => _progress;

  List<Map<String, dynamic>> _lstImages = [];
  List<Map<String, dynamic>> get lstImages => _lstImages;

  bool _isCharged = false;
  bool get isCharged => _isCharged;

  void setIsCharged(bool isCharged) {
    _isCharged = isCharged;
    notifyListeners();
  }

  int _selectedPage = 0;
  int get selectedPage => _selectedPage;

  void setSelectedPage(int selectedPage) {
    _selectedPage = selectedPage;
    notifyListeners();
  }

  void setLstImages(List<Map<String, dynamic>> lstImages) {
    _lstImages = lstImages;
    notifyListeners();
  }

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

  /*Stream<DocumentSnapshot<Map<String, dynamic>>> getAllImage(String userId) {
    try {
      return StorageRepository.instance.getAllImages(userId);
    } catch (e) {
      throw e;
    }
  }*/

  void getAllImage(String userId) async {
    try {
      var data = FirestoreRepository.instance.getImages(userId);
      data.listen((event) {
        lstImages.clear();
        _selectedPage = -1;
        print('event');
        print(event.get('images'));
        event.get('images').forEach((element) {
          _lstImages.add(element);
          _selectedPage++;
        });
        setIsCharged(true);
      });
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

  void addImageUrl(
      String url, String userId, String imageId, List<String> keywords) async {
    try {
      await FirestoreRepository.instance
          .addImageUrl(url, userId, imageId, keywords);
    } catch (e) {
      throw e;
    }
  }
}
