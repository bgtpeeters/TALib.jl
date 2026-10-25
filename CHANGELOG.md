# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-10-25

### Added
- `sma`, `ema`, `rsi`, `roc` — Simple/Exponential Moving Average, Relative Strength Index, Rate of Change
- `atr`, `dx` — Average True Range, Directional Movement Index
- `macd` — Moving Average Convergence/Divergence (returns line, signal, histogram)
- `bbands` — Bollinger Bands (returns upper, middle, lower)
- `stoch` — Stochastic oscillator (returns slow %K, slow %D)

### Changed
- All indicators return arrays of the same length as the input, NaN-padded over the lookback period

### Fixed
- Non-contiguous inputs (ranges, strided or reversed views) are now copied to a contiguous
  array before being passed to TA-Lib; previously they produced wrong results or failed
- High/low/close indicators now throw `DimensionMismatch` when input lengths differ,
  instead of reading past the end of the shorter arrays

### Removed
- Redundant `[extras]`/`[targets]` test section from `Project.toml` (`test/Project.toml` is used)

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

[Unreleased]: https://github.com/bgtpeeters/TALib.jl/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/bgtpeeters/TALib.jl/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/bgtpeeters/TALib.jl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bgtpeeters/TALib.jl/releases/tag/v0.1.0
