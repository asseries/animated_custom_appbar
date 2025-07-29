
---

## ✅ `CHANGELOG.md`
```md
## [1.0.0] - 2025-07-18
- Initial release of AnimatedCustomAppBar


## [1.0.1] - 2025-07-28

### Changed
- `children: []` now accepts regular widgets instead of requiring `slivers: []`. This improves ease of use and flexibility when adding scrollable content.

### Added
- `baseBackgroundColor` property to customize the base layer behind all content.
- `backgroundImageColorAlpha` to control the opacity overlay on top of the background image.
- `curve` parameter added for smoother animation customization.
- `physics` parameter added to allow custom scroll behavior.

### Fixed
- Minor bug fixes and internal refactoring.
- Improved inline documentation and code comments.

## [1.0.2] - 2025-07-29

### Added
- Added `onRefresh` callback to support pull-to-refresh using `RefreshIndicator`.


