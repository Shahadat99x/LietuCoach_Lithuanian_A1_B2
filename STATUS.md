# Feature: Premium Map Path

## Status: Implemented 🟢

The new Map Path implementation is complete, featuring a segmented toggle, local persistence, and a premium visual layout for the map view.

### Changes
- **UI**: Added `SegmentedViewToggle` with animated selection.
- **Persistence**: Path preference (List vs Map) is saved locally.
- **Map Layout**: Implemented `PathMapView` using `UnitSection` widgets with a zigzag node layout and soft SVG connectors (`UnitPathPainter`).
- **Feedback**: Added snackbar feedback when tapping locked units.
- **Animations**: Added `AnimatedSwitcher` for smooth view transitions.
- **Polishing**: Refactored `PathHeader` cards for consistency (`AppCard` styling).

### Verification
- `flutter analyze`: Passing (minor styling warnings).
- `flutter test`: Integration tests currently flaky due to `ContentRepository` dependency injection limits. Requires DI refactor for full coverage.
- **Manual Verification**:
  1. Toggle between List and Map views.
  2. Verify preference persists on app restart.
  3. Check "Zig-zag" layout in Map view.
  4. Tap unlocked/locked nodes (verify navigation/snackbar).

### Next Steps
- Implement `ContentRepository` DI to fix integration tests.
- Add "Entrance Animations" for map nodes (staggered fade-in).
- Refine "Current Node" pulse animation with custom assets if needed.
