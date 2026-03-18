---
name: calendly-booking
description: Check upcoming demo bookings and availability on Calendly for PropRooster Demo event
metadata:
  openclaw:
    emoji: 📅
    requires:
      bins:
        - curl
    env:
      - CALENDLY_BOOKING_URL
---

# Calendly Booking Skill

Check upcoming PropRooster Demo bookings via Calendly.

**Booking URL:** Use `CALENDLY_BOOKING_URL` from env (e.g. `https://calendly.com/aviv-proprooster/proprooster-demo`).

## Usage

The booking URL is included in Email 1 as the CTA. Calendly handles scheduling automatically.

## TODO

- [ ] Build Calendly API integration for checking bookings programmatically
- [ ] Add webhook for new booking notifications to Telegram
