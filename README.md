# Crystal Estates Hub

Rent, car wash and expense manager for Crystal Estates — installable web app (PWA).

**Live app:** https://zamirka25.github.io/crystal-estates-hub/

## What it manages
- **Awali Building** — 18 rooms + 1 ground-floor shop (let to a hairdresser)
- **Iskan Building** — 64 flats
- **Crystal Gloss Car Wash** — automatic and manual wash takings

## Features
- Month-by-month rent board for every unit: Paid / Partial / Due / Overdue / Vacant
- One-tap "Record payment" pre-filled with the unit's rent
- Units & tenants register (tenant, phone, rent, due day, occupancy, notes)
- Daily car wash takings with automatic vs manual split
- Expense tracking by property and category
- Management reports: collection rate, income vs expenses, 12-month trend, print-to-PDF, CSV export, copy-to-WhatsApp summary
- Reminders for overdue rent (notifications on app open)
- Installable on phone and desktop (PWA), works offline
- JSON backup export / import

## Notes
- Data lives in a shared cloud database (Supabase) with team login — everyone sees changes live.
- Team members are managed in the Supabase dashboard (Authentication → Users).
- First-time database setup: run `crystal-setup.sql` in the Supabase SQL Editor.
- The app seeds the 83 standard units automatically on first sign-in.

Built July 2026.
