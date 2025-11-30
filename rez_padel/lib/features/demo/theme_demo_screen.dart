import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Demo screen to showcase the Rez Padel theme
/// Hot Pink (#FF0099) and Deep Navy (#1a2332) with Montserrat font
class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rez Padel Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_tennis),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Center(
              child: Column(
                children: [
                  Text(
                    'Rez Padel',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rezerviši svoj teren',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Typography Showcase
            Text(
              'Typography',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Headline Large - Montserrat ExtraBold',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Title Large - Montserrat Bold',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Body Large - Montserrat Regular. Ovo je primer teksta koji bi bio korišćen u aplikaciji za rezervaciju padel terena.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Buttons
            Text(
              'Buttons',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Rezerviši Teren'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Pogledaj Termine'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Text('Saznaj Više'),
            ),
            const SizedBox(height: 32),

            // Cards
            Text(
              'Cards',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_tennis,
                          color: AppColors.hotPink,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Teren 1',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unutrašnji teren sa profesionalnom podlogom. Idealan za igru u svim vremenskim uslovima.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2.500 RSD / sat',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.hotPink,
                                  ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Rezerviši'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Input Fields
            Text(
              'Input Fields',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'ime@primer.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Lozinka',
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 32),

            // Color Palette
            Text(
              'Color Palette',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ColorBox(
                    color: AppColors.hotPink,
                    name: 'Hot Pink',
                    hex: '#FF0099',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorBox(
                    color: AppColors.deepNavy,
                    name: 'Deep Navy',
                    hex: '#1a2332',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ColorBox(
                    color: AppColors.limeGreen,
                    name: 'Lime Green',
                    hex: '#00FF66',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ColorBox(
                    color: AppColors.surfaceDark,
                    name: 'Surface',
                    hex: '#252d3d',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String name;
  final String hex;

  const _ColorBox({
    required this.color,
    required this.name,
    required this.hex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color == AppColors.deepNavy ||
                            color == AppColors.surfaceDark
                        ? AppColors.white
                        : AppColors.deepNavy,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              hex,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color == AppColors.deepNavy ||
                            color == AppColors.surfaceDark
                        ? AppColors.textSecondary
                        : AppColors.deepNavy,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

