// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Session {
  final int id;
  final Data salle;
  final int heure_deb;
  final int heure_fin;
  final Course course;
    bool validate=false;

  Session(
      {required this.id,
      required this.salle,
      required this.heure_deb,
      required this.heure_fin,
      required this.course});
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
        id: json["id"] as int,
        salle: Data.fromJson(json["salle"]),
        heure_deb: json["heure_deb"],
        heure_fin: json["heure_fin"],
        course: Course.fromJson(json["course"]));
  }
}

class Data {
  final int id;
  final String libelle;

  Data({required this.id, required this.libelle});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(id: json["id"], libelle: json["libelle"]);
  }
}

class Personn {
  final int id;
  final String nom;
  Personn({required this.id, required this.nom});
  factory Personn.fromJson(Map<String, dynamic> json) {
    return Personn(id: json["id"], nom: json["nom"]);
  }
}

class Course {
  final int id;
  final Data annee;
  final Data semestre;
  final Data classe;
  final Data module;
  final Personn professeur;

  Course(
      {required this.id,
      required this.annee,
      required this.semestre,
      required this.classe,
      required this.module,
      required this.professeur});
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
        id: json["id"],
        annee: Data.fromJson(json["annee"]),
        semestre: Data.fromJson(json["semestre"]),
        classe: Data.fromJson(json["classe"]),
        module: Data.fromJson(json["module"]),
        professeur: Personn.fromJson(json["professeur"]));
  }
}
