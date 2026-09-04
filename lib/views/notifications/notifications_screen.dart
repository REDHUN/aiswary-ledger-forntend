import 'package:ashgledger/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/di/service_locator.dart';
import '../../core/model/notification_model.dart';
import '../../core/repository/notification_repository.dart';
import '../../core/services/notification_router.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationRepository? repository;
  const NotificationsScreen({super.key, this.repository});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationRepository _repository;
  final ScrollController _scrollController = ScrollController();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<NotificationRepository>();
    _fetchNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreNotifications();
    }
  }

  Future<void> _fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
    }
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getNotifications(page: _page, size: 20);
      if (mounted) {
        setState(() {
          if (refresh) {
            _notifications = items;
          } else {
            _notifications.addAll(items);
          }
          _hasMore = items.length == 20;
          _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final items = await _repository.getNotifications(page: _page, size: 20);
      if (mounted) {
        setState(() {
          _notifications.addAll(items);
          _hasMore = items.length == 20;
          _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more notifications: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _handleNotificationTap(NotificationItem item, int index) async {
    final storage = sl<StorageService>();
    if (!item.isRead) {
      await _repository.markAsRead(item.id);
      if (mounted) {
        setState(() {
          _notifications[index] = item.copyWith(isRead: true);
        });
      }
    }
    if (mounted) {
      if (storage.isAdmin()) {
      } else {
        NotificationRouter.navigateFromNotification(
          context,
          type: item.notificationType.name,
          referenceId: item.referenceId?.toString(),
          data: item.data,
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    await _repository.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.MEETING:
        return Icons.event_note_rounded;
      case NotificationType.MEETING_REPORT:
        return Icons.menu_book_rounded;
      case NotificationType.PAYMENT:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.LOAN:
        return Icons.monetization_on_rounded;
      case NotificationType.FINE:
        return Icons.warning_amber_rounded;
      case NotificationType.ANNOUNCEMENT:
        return Icons.campaign_rounded;
      case NotificationType.GENERAL:
      case NotificationType.TEST:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.MEETING:
        return Colors.blue;
      case NotificationType.MEETING_REPORT:
        return Colors.indigo;
      case NotificationType.PAYMENT:
        return Colors.green;
      case NotificationType.LOAN:
        return Colors.amber.shade800;
      case NotificationType.FINE:
        return Colors.redAccent;
      case NotificationType.ANNOUNCEMENT:
        return Colors.purple;
      case NotificationType.GENERAL:
      case NotificationType.TEST:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: _notifications.any((n) => !n.isRead)
                ? _markAllAsRead
                : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchNotifications(refresh: true),
        child: _isLoading && _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No notifications yet',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final item = _notifications[index];
                  final color = _getNotificationColor(item.notificationType);
                  return Material(
                    color: item.isRead
                        ? Colors.transparent
                        : Colors.blue.withValues(alpha: 0.05),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          _getNotificationIcon(item.notificationType),
                          color: color,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(item.body, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimeAgo(item.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _handleNotificationTap(item, index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
