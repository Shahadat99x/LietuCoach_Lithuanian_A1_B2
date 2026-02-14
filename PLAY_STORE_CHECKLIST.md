# Play Store Release Checklist — LietuCoach

## Store Listing URLs

| Field            | URL                                         |
| ---------------- | ------------------------------------------- |
| Privacy Policy   | https://lietucoach.vercel.app/privacy       |
| Terms of Service | https://lietucoach.vercel.app/terms         |
| Data Deletion    | https://lietucoach.vercel.app/data-deletion |
| Support          | https://lietucoach.vercel.app/support       |
| Support Email    | hello@dhossain.com                          |

## Data Safety Answers

| Question                        | Answer                                      |
| ------------------------------- | ------------------------------------------- |
| Collects user data?             | Yes — optional account (Google sign-in)     |
| Shares data with third parties? | No                                          |
| Ads or ad tracking?             | **No**                                      |
| Analytics/crash reporting?      | **No**                                      |
| Location data?                  | **No**                                      |
| Contacts/phone?                 | **No**                                      |
| Data encrypted in transit?      | Yes (HTTPS/TLS)                             |
| Users can request deletion?     | Yes                                         |
| Data deletion mechanism         | In-app: Profile → Delete Account            |
| Data deletion URL               | https://lietucoach.vercel.app/data-deletion |

## Account Deletion

- **In-app path**: Profile → Delete Account
- **Web policy**: https://lietucoach.vercel.app/data-deletion
- **What is deleted**: Profile, lesson progress, SRS cards, streak stats, certificate metadata
- **Timeframe**: Immediate (Supabase Edge Function)

## App Identity

| Field        | Value                       |
| ------------ | --------------------------- |
| Package name | `app.lietucoach.lietucoach` |
| Version      | `1.0.0`                     |
| Build number | `2`                         |
| Min SDK      | Flutter default             |
| Target SDK   | Flutter default             |

## Build Command

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Pre-Upload Checklist

- [ ] AAB builds successfully
- [ ] No debug banner in release
- [ ] No hardcoded dev/staging endpoints
- [ ] No secrets in the bundle
- [ ] Privacy Policy URL is live and accessible
- [ ] Terms URL is live and accessible
- [ ] Data Deletion URL is live and accessible
- [ ] Support URL is live and accessible
- [ ] App icon is correct (not Flutter default)
- [ ] Splash screen is branded
