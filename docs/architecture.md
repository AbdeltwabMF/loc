# Architecture

## Goals

- Alarm reliably while an active journey is running.
- Keep reminders usable without network access.
- Isolate platform and public API failures from UI and stored data.
- Minimize dependencies and avoid generated state-management code.
- Preserve v0.6 Hive data and type IDs.

## Layers

### UI

The shell contains Reminders, Saved Places, and Settings. Search and status
filters are part of the reminder list. Reminder editing and map selection are
routes because they represent focused, reversible tasks.

Pages consume `AppController` and render immutable list snapshots. They never
hold location subscriptions or Hive boxes.

### Application

`AppController` is the single coordinator. It owns the current position,
tracking lifecycle, arrival transitions, alarm lifecycle, theme preference, and
collection mutations. The controller updates all changed reminders for one GPS
sample and notifies the UI after the batch.

This intentionally avoids a larger clean-architecture framework. The app has
one local aggregate and two external boundaries; additional use-case classes
would add indirection without reducing coupling.

### Data and platform boundaries

- `AppRepository` is the only Hive boundary and persists mutations immediately.
- `LocationService` owns permission checks and Geolocator configuration.
- `GeocodingService` owns Nominatim policy, HTTP parsing, limits, and timeouts.
- `Reminder`, `Place`, and `Point` remain Hive-compatible domain objects.

Reverse geocoding is optional enrichment. A valid coordinate can always be
saved, so an unavailable map service cannot block the core offline workflow.

## Arrival semantics

A reminder arrives when a measured position is inside its configured radius or
the path segment between consecutive GPS samples intersects that radius. The
second condition prevents a vehicle from crossing a small arrival zone between
samples without detection. Only enabled reminders participate.

Saving or enabling a reminder immediately evaluates the latest in-memory
position, so editing a destination while stationary does not wait for movement
to produce another GPS event. Once arrived, a reminder remains in that state
until the measured position is more than 25 m beyond its configured radius.
This exit buffer prevents GPS jitter near the boundary from repeatedly clearing
and retriggering an alert. Leaving clears the arrival and acknowledgement state,
stops that visit's alert, and permits a future arrival. Location tracking itself
continues until every reminder is disabled or deleted.

Each reminder selects a brief notification, a silent vibration, or an insistent
alarm. Brief alerts use normal notification audio once. Vibration alerts use a
silent channel with an explicit vibration pattern. Alarms use Android's alarm
audio attributes and repeat until dismissed. All remain subject to Android
channel, permission, and Do Not Disturb settings.

Tracking uses an Android foreground service with a visible ongoing notification
while at least one reminder is enabled. It requests high-accuracy updates with a
10 m distance filter and 3 second interval while active. Android treats these as
requests rather than hard real-time guarantees and may delay samples. Segment
intersection covers skipped zones, but GPS outages, tunnels, and OS scheduling
can still delay an alert.

Android may stop apps after force-stop, reboot, OEM battery restrictions, or
permission removal. Supporting those cases requires native geofencing plus boot
re-registration, which should be treated as a separate reliability feature and
tested on physical OEM devices rather than hidden behind a workaround.

## Persistence compatibility

Hive type IDs and existing field numbers are unchanged. Reminder fields 8 and 9
store the alarm and vibration choices and default to a brief alert when absent.
Old length metadata and numeric keys are ignored while typed values are loaded.
Editing an old reminder removes its numeric entry and writes one ID-keyed entry,
preventing duplicates. Saved places within 25 m are consolidated during
migration and rejected as duplicate additions afterward.

## Error policy

- Permission and service errors remain visible next to active reminders.
- Enabling tracking reports permission failures and does not fake success.
- Network search errors are transient snackbars and never corrupt editor state.
- Persistence is awaited before a mutation is considered complete.

## Future work

- Replace continuous tracking with native Android geofences for reboot and
  process-death resilience.
- Add encrypted export/import if users need device migration.
- Add localization after product copy and supported locales are defined.
