//function format money
String formatMoneyVND(num amount) {
  if (amount >= 1000000) {
    // Quy đổi sang "triệu"
    double tr = amount / 1000000;
    if (tr % 1 == 0) {
      return '${tr.toInt()}tr';
    } else {
      // Giữ 1 số sau dấu phẩy, ví dụ 8.3tr
      return '${tr.toStringAsFixed(1).replaceAll('.0', '')}tr';
    }
  } else if (amount >= 1000) {
    // Nếu dưới 1 triệu, hiển thị nghìn
    double k = amount / 1000;
    if (k % 1 == 0) {
      return '${k.toInt()}k';
    } else {
      return '${k.toStringAsFixed(1).replaceAll('.0', '')}k';
    }
  } else {
    // Dưới 1000 giữ nguyên
    return amount.toString();
  }
}
//function format time
String timeAgo(dynamic date) {
  if (date == null) return "Không xác định";

  DateTime parsed;
  try {
    if (date is int) {
      // Epoch milliseconds
      parsed = DateTime.fromMillisecondsSinceEpoch(date);
    } else if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      // Fix lỗi định dạng "2025-11-12 07:30:00"
      final fixed = date.contains('T') ? date : date.replaceAll(' ', 'T');
      parsed = DateTime.parse(fixed);
    } else {
      return "Không xác định";
    }
  } catch (e) {
    print("⚠️ timeAgo parse error: $e (input: $date)");
    return "Không xác định";
  }

  final now = DateTime.now();
  final diff = now.difference(parsed);

  if (diff.inMinutes < 1) return "Vừa xong";
  if (diff.inHours < 1) return "${diff.inMinutes} phút trước";
  if (diff.inDays < 1) return "${diff.inHours} giờ trước";
  if (diff.inDays < 30) return "${diff.inDays} ngày trước";
  if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} tháng trước";
  return "${(diff.inDays / 365).floor()} năm trước";
}
