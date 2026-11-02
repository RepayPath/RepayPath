# RepayPath

UK student loan payoff planner. Pure SwiftUI, iOS 17+, **fully offline** — no accounts, no network calls, no third-party SDKs, no analytics, no ads.

> Independent tool. Not affiliated with, endorsed by, or connected to the Student Loans Company, HMRC, or the UK government.

## What it does

Given a repayment plan, current balance, salary and a few assumptions, it estimates:

- the monthly deduction
- whether the loan is ever repaid in full, and if so **which month and year**
- the write-off date if it is not repaid (25/30/40 years depending on plan)
- total interest paid before payoff or write-off
- how much earlier the loan is cleared if you overpay (slider + presets)

All arithmetic runs on device. Saved plans live in `UserDefaults`.

## Rules and data provenance

Thresholds, percentages and write-off periods come from
`https://www.gov.uk/repaying-your-student-loan` — **verified 2 November 2026**:

| Plan | Monthly threshold | Rate | Write-off |
|---|---|---|---|
| Plan 1 | £2,241 | 9% | 25 years |
| Plan 2 | £2,448 | 9% | 30 years |
| Plan 4 | £2,816 | 9% | 30 years |
| Plan 5 | £2,083 | 9% | 40 years |
| Postgraduate | £1,750 | 6% | 30 years |

Interest is **not hard-coded**: the government sets it monthly, so the app exposes it as an adjustable input instead of shipping a number that silently goes stale.

Reference implementation used to validate the Swift engine before writing UI:
`tools/` (Python) — reproduces the two official examples exactly
(Plan 1, £33,000 → £45.81/month; Plan 4, £36,000 → £16.56/month).

## Project layout

```
RepayPath.xcodeproj/            hand-maintained pbxproj (no Xcode needed to edit)
RepayPath/
  RepayPathApp.swift            @main + AppState
  Models/
    LoanPlan.swift              plan enum: thresholds, rate, write-off years
    Simulator.swift             the engine (pure functions)
    SimulationResult.swift      result + chart point types
    Scenario.swift              a saved plan
    ScenarioStore.swift         UserDefaults persistence
  Support/
    Money.swift                 £ formatting / parsing
    Formatters.swift            month-year labels, durations
    L10n.swift                  all user-facing strings (EN/ZH)
  Views/
    RootView.swift              TabView shell
    PlanInputView.swift         inputs
    ResultView.swift            headline result + conclusion card + chart
    BalanceChartView.swift      Swift Charts timeline
    CompareView.swift           overpayment comparison + saved plans
    InfoView.swift              rules, sources, disclaimer, privacy
  Resources/
    Assets.xcassets/            AppIcon (1024, no alpha) + AccentColor
    en.lproj, zh-Hans.lproj     Localizable.strings
codemagic.yaml                  compile-check + signed ios-build
```

## Bundle ID

Set to **`com.fumikothelen.repaypath`** in:

1. `RepayPath.xcodeproj/project.pbxproj` (Debug and Release configs)
2. `codemagic.yaml` → `ios_signing.bundle_identifier`
3. `codemagic.yaml` → `app-store-connect fetch-signing-files`

It must match the App ID registered in the developer account, and **cannot be changed after release**.

Apple Team ID: `V58Z48NR6K` · Bundle ID: `com.fumikothelen.repaypath`

## Build

Cloud-only (no Mac required):

1. Push this repo to GitHub (upload the **contents** of this folder, not the folder itself)
2. Codemagic → add application → Native iOS
3. Settings → Integrations → Developer Portal → add the App Store Connect API key (`.p8` + Key ID + Issuer ID) and name it `RepayPathIntegration`
4. Run `compile-check` first, then `ios-build`

## App Review Notes (paste into App Store Connect)

> RepayPath is an offline planning calculator for student loan repayments.
>
> To verify: open the app → the first tab has four inputs (repayment plan, balance, salary, interest rate) with sensible defaults → the second tab shows the monthly deduction, the payoff date (or the write-off date if the loan is never repaid), total interest, and a balance-over-time chart → the third tab demonstrates overpayment scenarios → the fourth tab lists the GOV.UK rules and sources used.
>
> No account, no login, no network connection, no permissions are requested. Nothing is collected. All figures are derived from publicly available GOV.UK rules (verified 2 November 2026) and are estimates only — the app states this in the About tab.
>
> No in-app purchases, no subscriptions, no advertising.

## Deliberately absent

- No networking layer, no URLSession use
- No third-party dependencies
- No permissions (no photo library, no location, no notifications)
- No debug/demo hooks or launch-argument branches in the release build
