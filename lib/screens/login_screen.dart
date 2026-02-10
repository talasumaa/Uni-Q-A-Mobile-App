import 'package:flutter/material.dart';
import '../app/app_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final users = state.users;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign in",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose a profile to continue. (Local demo login)",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final subtitle = [
                      if ((u.program ?? "").trim().isNotEmpty) u.program!.trim(),
                      if ((u.semester ?? "").trim().isNotEmpty) u.semester!.trim(),
                    ].join(" • ");

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => state.login(u.id),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: Text(
                                  (u.displayName.isNotEmpty ? u.displayName[0] : "?")
                                      .toUpperCase(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                    if (subtitle.trim().isNotEmpty)
                                      Text(
                                        subtitle,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                "Note: This is a local-only demo. In a real app, this would be replaced by proper authentication.",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
