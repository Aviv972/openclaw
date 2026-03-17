---
name: calcom-booking
description: Check upcoming demo bookings and availability on Cal.com for PropRooster Demo event
metadata:
  openclaw:
    emoji: 📅
    requires:
      bins:
        - xurl
    env:
      - CALCOM_API_KEY
---

# Cal.com Booking Skill

Check upcoming PropRooster Demo bookings and available slots via the Cal.com v1 API.

## Usage

List upcoming bookings:

```
calcom-booking list
```

Check availability for the next 7 days:

```
calcom-booking availability
```

Check availability for a specific date range:

```
calcom-booking availability from="2026-03-20" to="2026-03-27"
```

## Implementation

### List Upcoming Bookings

```bash
xurl GET "https://api.cal.com/v1/bookings?apiKey=$CALCOM_API_KEY&status=upcoming" \
  -H "Content-Type: application/json"
```

### Check Availability

```bash
xurl GET "https://api.cal.com/v1/availability?apiKey=$CALCOM_API_KEY&eventTypeId=[PROPROTSER_DEMO_EVENT_ID]&startTime=[from]T00:00:00Z&endTime=[to]T23:59:59Z" \
  -H "Content-Type: application/json"
```

> Set `PROPROTSER_DEMO_EVENT_ID` to the Cal.com event type ID for "PropRooster Demo" after creating it in Cal.com setup.

## Output Format

### Upcoming Bookings

```
Upcoming PropRooster Demo calls:

1. [Date, Time Lisbon] — [Attendee name] ([Agency])
   Email: [attendee email]
   Zoom: [meeting link]

2. [Date, Time Lisbon] — ...

Total booked: [count]
```

### Availability

```
Available slots (Mon–Fri, 10:00–17:00 Lisbon):

[Date]: [10:00, 10:30, 11:00, ...] (n slots)
[Date]: [10:00, 11:00, ...] (n slots)

Fully booked: [list any fully booked days]
```

## Event Configuration Reference

The "PropRooster Demo" event on Cal.com should be configured as:
- Duration: 30 minutes
- Auto-generate Zoom link: enabled
- Buffer: 15 min before/after
- Availability: Mon–Fri, 10:00–17:00 Europe/Lisbon
- Booking confirmation: automatic email to attendee

## Error Handling

- If `CALCOM_API_KEY` is not set → abort with: "Error: CALCOM_API_KEY env var not set. Add it to ~/.openclaw/.env"
- If API returns 401 → abort with: "Error: Cal.com API key invalid or expired"
- If no bookings found → report: "No upcoming PropRooster Demo bookings."
- If no availability found → report: "No available slots in the requested range. Check Cal.com availability settings."
