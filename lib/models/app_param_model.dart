class AppParamModel {
  final bool hideVoyanceAndroidAds;
  final bool hideVoyanceAdsIos;
  final List<String> appVersionList;
  final String? voyanceandroidLink;
  final String? voyanceiosLink;

  AppParamModel({
    required this.hideVoyanceAndroidAds,
    required this.hideVoyanceAdsIos,
    required this.appVersionList,
    this.voyanceandroidLink,
    this.voyanceiosLink,
  });

  factory AppParamModel.fromJson(Map<String, dynamic> json) => AppParamModel(
        hideVoyanceAndroidAds: json['hideVoyanceAndroidAds'] ?? false,
        hideVoyanceAdsIos: json['hideVoyanceAdsIos'] ?? false,
        appVersionList: List<String>.from(json['appVersionList'] ?? []),
        voyanceandroidLink: json['voyanceandroidLink'],
        voyanceiosLink: json['voyanceiosLink'],
      );
}
