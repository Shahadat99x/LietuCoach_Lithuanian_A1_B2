# Delete Account Edge Function

## Deploy Command

```bash
supabase functions deploy delete-account --project-ref vdxmuhstoizfbsulhrml
```

## Operational Mode

- Preferred mode: **Verify JWT ON** (gateway auth enabled).
- Function also validates JWT internally via `adminClient.auth.getUser(accessToken)`.
- Flutter client should default to `functions.invoke('delete-account')` with SDK-managed headers.

## Fallback (Only If ON Cannot Be Stabilized)

```bash
supabase functions deploy delete-account --project-ref vdxmuhstoizfbsulhrml --no-verify-jwt
```

If fallback is used:
- Keep strict in-function JWT validation as the first guard.
- Never accept `user_id` from the request body.
- Re-test unauthenticated requests: must return 401 and perform no deletes.
