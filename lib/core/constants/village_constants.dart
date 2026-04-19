class VillageConstants {
  const VillageConstants._();

  // Phase 1 launch village (El Haya, Abusir, Giza). Future phases resolve the
  // active villageId from the enrollment deep-link `hayati://enroll/v/{id}`
  // per hayati-architecture.md §3. Until that deep-link is implemented, this
  // default is used when the user enrolls without a deep link.
  static const String defaultVillageId = 'abusir';

  // Cloud Functions region per hayati-architecture.md §3.
  static const String functionsRegion = 'europe-west1';
}
