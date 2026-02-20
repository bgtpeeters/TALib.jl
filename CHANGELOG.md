# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-02-20

### Fixed
- Corrected ADX lookback formula in tests and README: `2*p - 1` (not `2*(p-1)`)

## [0.1.0] - 2026-02-20

### Added
- Initial release
- `wma(prices, period)` — Weighted Moving Average
- `adx(high, low, close, period)` — Average Directional Movement Index
- `minus_di(high, low, close, period)` — Minus Directional Indicator (−DI)
- `plus_di(high, low, close, period)` — Plus Directional Indicator (+DI)
- GitHub Actions CI (Julia 1.6, 1.10, latest on ubuntu-latest)
- BSD 2-Clause license

[Unreleased]: https://github.com/bgtpeeters/TALib.jl/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/bgtpeeters/TALib.jl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bgtpeeters/TALib.jl/releases/tag/v0.1.0
