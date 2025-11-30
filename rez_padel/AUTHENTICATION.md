# Authentication System Documentation

## Overview

The authentication system uses **Supabase Auth** for identity management and a **PostgreSQL Trigger** to automatically create user profiles in the `public.users` table. This approach avoids complex client-side Row Level Security (RLS) issues during sign-up.

## Architecture

1.  **Flutter App**: Collects user info (email, password, name, phone).
2.  **Supabase Auth**: Creates the user identity in `auth.users`.
3.  **Database Trigger**: Automatically inserts a corresponding row into `public.users`.

## Database Setup

### 1. The Trigger Function
This function runs with `SECURITY DEFINER` privileges (admin rights) to bypass RLS restrictions during profile creation.

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, first_name, last_name, phone, role, created_at, updated_at)
  VALUES (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name',
    new.raw_user_meta_data ->> 'phone',
    'player',
    NOW(),
    NOW()
  );
  RETURN new;
END;
$$;
```

### 2. The Trigger
Fires immediately after a new user is added to `auth.users`.

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 3. RLS Policies (public.users)
Since the Trigger handles creation, the client-side RLS policies can be simple:

*   **SELECT**: `auth.uid() = id` (User sees own profile)
*   **UPDATE**: `auth.uid() = id` (User updates own profile)
*   **INSERT**: Not strictly needed for users anymore, but `true` or `auth.uid() = id` is fine.

## Flutter Implementation

### AuthRepository (`lib/features/auth/data/auth_repository.dart`)

We pass user details as **Metadata** (`data` map) during the sign-up call. This metadata is what the Trigger reads (`new.raw_user_meta_data`).

```dart
Future<AuthResponse> signUpWithEmailAndPassword({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String phone,
}) async {
  // Metadata passed here is accessible by the DB Trigger
  return await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    },
  );
}
```

### AuthController (`lib/features/auth/presentation/auth_controller.dart`)

Manages the state using Riverpod. It listens to `onAuthStateChange` to automatically update the UI when a user logs in or out.

## Troubleshooting

**Issue: Sign-up succeeds (no error), but `public.users` is empty.**
*   **Cause:** The Trigger failed to fire or encountered an error.
*   **Fix:** Check Supabase Database > Postgres Logs. Ensure the `handle_new_user` function exists and has `SECURITY DEFINER`.

**Issue: "AppConstants.supabaseAnonKey" not found.**
*   **Cause:** `dart_defines.json` missing or not passed.
*   **Fix:** Ensure `flutter run` includes the config or the key is hardcoded in `AppConstants.dart`.

