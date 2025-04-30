import 'package:flutter/material.dart';

class PendingOrders extends StatelessWidget {
  const PendingOrders({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual order data from your backend
    final orders = [
      {
        'id': 'ORD001',
        'date': '2024-03-15',
        'items': 3,
        'total': '\$150.00',
        'status': 'Processing',
      },
      {
        'id': 'ORD002',
        'date': '2024-03-14',
        'items': 2,
        'total': '\$75.50',
        'status': 'Shipped',
      },
      {
        'id': 'ORD003',
        'date': '2024-03-13',
        'items': 1,
        'total': '\$45.00',
        'status': 'Delivered',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.shopping_bag,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              'Order ${order['id'] as String}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order['date'] as String),
                Text('${order['items'] as int} items'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order['total'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  order['status'] as String,
                  style: TextStyle(
                    color: _getStatusColor(order['status'] as String),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to order details
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
 