import 'package:flutter/material.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual transaction data from your backend
    final transactions = [
      {
        'id': '1',
        'date': '2024-03-15',
        'amount': '\$150.00',
        'status': 'Completed',
        'type': 'Purchase',
      },
      {
        'id': '2',
        'date': '2024-03-14',
        'amount': '\$75.50',
        'status': 'Pending',
        'type': 'Refund',
      },
      {
        'id': '3',
        'date': '2024-03-13',
        'amount': '\$200.00',
        'status': 'Completed',
        'type': 'Purchase',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                transaction['type'] == 'Purchase'
                    ? Icons.shopping_bag
                    : Icons.receipt,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              transaction['type']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(transaction['date']!),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction['amount']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  transaction['status']!,
                  style: TextStyle(
                    color: transaction['status'] == 'Completed'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to transaction details
            },
          ),
        );
      },
    );
  }
}
