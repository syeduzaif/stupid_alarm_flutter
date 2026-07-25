/// Derives stable notification ids from alarm id strings.
///
/// Android requires notification ids to fit in a signed 32-bit int, but this
/// app's alarm ids are millisecond-timestamp strings (13+ digits), so the ids
/// are hashed (FNV-1a) instead of parsed. The same key always produces the
/// same id, which is what lets us cancel a notification we scheduled in an
/// earlier app session.
int notificationIdFor(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
