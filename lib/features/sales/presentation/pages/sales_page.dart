import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sales_bloc.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesInitial) {
            return const Center(
              child: Text('Click the button to load sales'),
            );
          }
          
          if (state is SalesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is SalesLoaded) {
            if (state.sales.isEmpty) {
              return const Center(
                child: Text('No sales found'),
              );
            }
            
            return ListView.builder(
              itemCount: state.sales.length,
              itemBuilder: (context, index) {
                final sale = state.sales[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Sale #${sale.id}'),
                    subtitle: Text('Total: \$${sale.totalAmount.toStringAsFixed(2)}'),
                    trailing: Text(sale.status),
                    onTap: () {
                      // TODO: Navigate to sale detail
                    },
                  ),
                );
              },
            );
          }
          
          if (state is SalesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SalesBloc>().add(const LoadSales());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<SalesBloc>().add(const LoadSales());
        },
        tooltip: 'Load Sales',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
