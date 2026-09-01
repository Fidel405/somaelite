Supabase setup (manual steps)

1. Create a Supabase project at https://app.supabase.com/ and note the Database connection string and API keys.
2. In your deployment or locally, set environment variables:
   - DATABASE_URL (Postgres connection string) — used by the migration runner
   - NEXT_PUBLIC_SUPABASE_URL (for frontend)
   - NEXT_PUBLIC_SUPABASE_ANON_KEY (for frontend)
   - SUPABASE_SERVICE_ROLE_KEY (only for server-side privileged tasks; keep secret)

3. Run migrations locally against your Supabase DB:
   - In repo root, run: (from web folder) `node scripts/run_migrations.js` after setting DATABASE_URL.
   - Example (PowerShell): `$env:DATABASE_URL = "postgres://..."; node web\scripts\run_migrations.js`

4. Seed curricula/subjects or use the Supabase SQL editor to run db/migrations/001_create_schema.sql directly.

Notes:
- Do NOT commit service role keys to git. Use environment variables in Vercel/HostAfrica.
- After migrations, the frontend can read lessons via the lessons table and cache them offline.
