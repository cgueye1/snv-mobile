class AppParamModel {
  final bool hideVoyanceAndroidAds;
  final bool hideVoyanceAdsIos;
  final List<String> appVersionList;
  final String? voyanceandroidLink;
  final String? voyanceiosLink;
  final String? imageSponsor;
  final String? linkSponsor;

  AppParamModel({
    required this.hideVoyanceAndroidAds,
    required this.hideVoyanceAdsIos,
    required this.appVersionList,
    this.voyanceandroidLink,
    this.voyanceiosLink,
    this.imageSponsor,
    this.linkSponsor,
  });

  factory AppParamModel.fromJson(Map<String, dynamic> json) => AppParamModel(
    hideVoyanceAndroidAds: json['hideVoyanceAndroidAds'] ?? false,
    hideVoyanceAdsIos: json['hideVoyanceAdsIos'] ?? false,
    appVersionList: List<String>.from(json['appVersionList'] ?? []),
    voyanceandroidLink: json['voyanceandroidLink'],
    voyanceiosLink: json['voyanceiosLink'],
    imageSponsor: json['imageSponsor'],
    linkSponsor: json['linkSponsor'],
  );

  bool get hasSponsor =>
      imageSponsor != null &&
          imageSponsor!.isNotEmpty &&
          linkSponsor != null &&
          linkSponsor!.isNotEmpty;
}