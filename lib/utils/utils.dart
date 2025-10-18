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
String timeAgo(String dateString) {
  final dateTime = DateTime.parse(dateString).toLocal();
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return "vừa xong";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} phút trước";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} giờ trước";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} ngày trước";
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return "$weeks tuần trước";
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return "$months tháng trước";
  } else {
    final years = (difference.inDays / 365).floor();
    return "$years năm trước";
  }
}
