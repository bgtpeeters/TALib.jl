# TALib.jl

[![CI](https://github.com/bgtpeeters/TALib.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/bgtpeeters/TALib.jl/actions/workflows/ci.yml)
[![Julia 1.6+](https://img.shields.io/badge/Julia-1.6%2B-blue)](https://julialang.org)
[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD%202--Clause-orange.svg)](LICENSE)
[![Contributing](https://img.shields.io/badge/contributions-welcome-brightgreen)](CONTRIBUTING.md)

A Julia wrapper around the [TA-Lib](https://ta-lib.org/) technical analysis C
library. Bindings are implemented via Julia's built-in `ccall` — no code
generation, no external Julia dependencies, zero overhead compared to calling
the C library directly.

## Implemented indicators

| Julia function | TA-Lib function | Description | Inputs |
|---|---|---|---|
| `wma(prices, period)` | `TA_WMA` | Weighted Moving Average | price series |
| `sma(prices, period)` | `TA_SMA` | Simple Moving Average | price series |
| `ema(prices, period)` | `TA_EMA` | Exponential Moving Average | price series |
| `rsi(prices, period)` | `TA_RSI` | Relative Strength Index | price series |
| `roc(prices, period)` | `TA_ROC` | Rate of Change | price series |
| `atr(high, low, close, period)` | `TA_ATR` | Average True Range | H, L, C |
| `dx(high, low, close, period)` | `TA_DX` | Directional Movement Index | H, L, C |
| `adx(high, low, close, period)` | `TA_ADX` | Average Directional Movement Index | H, L, C |
| `minus_di(high, low, close, period)` | `TA_MINUS_DI` | Minus Directional Indicator (−DI) | H, L, C |
| `plus_di(high, low, close, period)` | `TA_PLUS_DI` | Plus Directional Indicator (+DI) | H, L, C |
| `macd(prices, fast, slow, signal)` | `TA_MACD` | Moving Average Convergence Divergence | price series |
| `bbands(prices, period, dev_up, dev_dn, ma_type)` | `TA_BBANDS` | Bollinger Bands | price series |
| `stoch(high, low, close, fastk, slowk, slowk_ma, slowd, slowd_ma)` | `TA_STOCH` | Stochastic Oscillator | H, L, C |

## Prerequisites

TALib.jl requires the **TA-Lib C shared library** to be installed on your
system. Julia itself has no dependency on any other package.

### Linux (Debian/Ubuntu) — recommended

```bash
# Download and install the pre-built .deb package
curl -LO https://github.com/ta-lib/ta-lib/releases/download/v0.6.4/ta-lib_0.6.4_amd64.deb
sudo dpkg -i ta-lib_0.6.4_amd64.deb
sudo ldconfig
```

For ARM64 (e.g. Raspberry Pi):
```bash
curl -LO https://github.com/ta-lib/ta-lib/releases/download/v0.6.4/ta-lib_0.6.4_arm64.deb
sudo dpkg -i ta-lib_0.6.4_arm64.deb
sudo ldconfig
```

### Linux (build from source)

```bash
curl -LO https://github.com/ta-lib/ta-lib/releases/download/v0.6.4/ta-lib-0.6.4-src.tar.gz
tar -xzf ta-lib-0.6.4-src.tar.gz
cd ta-lib-0.6.4
./configure
make
sudo make install
sudo ldconfig
```

> For other platforms (macOS, Windows) see the
> [TA-Lib install page](https://ta-lib.org/install).

## Installation

Once the C library is installed, add this package from the Julia REPL:

```julia
# From the Julia general registry (once published):
using Pkg
Pkg.add("TALib")

# Or directly from this repository:
Pkg.add(url="https://github.com/bgtpeeters/TALib.jl")

# For local development:
Pkg.develop(path="/path/to/TALib.jl")
```

## Usage

```julia
using TALib

# --- Weighted Moving Average ---
prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
wma_result = wma(prices, 3)

# --- Simple Moving Average ---
sma_result = sma(prices, 3)

# --- Exponential Moving Average ---
ema_result = ema(prices, 3)

# --- Relative Strength Index ---
rsi_result = rsi(prices, 5)

# --- Rate of Change ---
roc_result = roc(prices, 2)

# --- Moving Average Convergence Divergence ---
macd_line, macd_signal, macd_hist = macd(prices, 12, 26, 9)

# --- Bollinger Bands ---
upper_band, middle_band, lower_band = bbands(prices, 20, 2.0, 2.0, 0)

# --- Directional indicators (ADX, ±DI, DX) ---
high  = [10.0, 11.0, 12.0, 13.0, 12.0, 11.0, 12.0, 13.0, 14.0, 13.0,
         12.0, 13.0, 14.0, 15.0, 14.0, 13.0, 14.0, 15.0, 16.0, 15.0]
low   = [ 9.0, 10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0,
         11.0, 12.0, 13.0, 14.0, 13.0, 12.0, 13.0, 14.0, 15.0, 14.0]
close = [ 9.5, 10.5, 11.5, 12.5, 11.5, 10.5, 11.5, 12.5, 13.5, 12.5,
         11.5, 12.5, 13.5, 14.5, 13.5, 12.5, 13.5, 14.5, 15.5, 14.5]

atr_result      = atr(high, low, close, 5)      # volatility measure
dx_result       = dx(high, low, close, 5)       # trend strength [0, 100]
adx_vals        = adx(high, low, close, 5)      # trend strength [0, 100]
minus_di_vals    = minus_di(high, low, close, 5) # downward pressure [0, 100]
plus_di_vals     = plus_di(high, low, close, 5)  # upward pressure  [0, 100]

# --- Stochastic Oscillator ---
slowk, slowd = stoch(high, low, close, 5, 3, 0, 3, 0)
```

### Output length and alignment

All functions return only the **valid** portion of the output (TA-Lib skips
the initial "lookback" bars where there is insufficient data):

| Function | Output length | First output aligns with input index |
|---|---|---|
| `wma(prices, p)` | `n - p + 1` | `p` (1-based) |
| `sma(prices, p)` | `n - p + 1` | `p` (1-based) |
| `ema(prices, p)` | `n - p + 1` | `p` (1-based) |
| `rsi(prices, p)` | `n - p` | `p + 1` (1-based) |
| `roc(prices, p)` | `n - p` | `p + 1` (1-based) |
| `atr(hlc, p)` | `n - p` | `p + 1` (1-based) |
| `dx(hlc, p)` | `n - (2*p - 2)` | `2*p - 1` (1-based) |
| `adx(hlc, p)` | `n - (2*p - 1)` | `2*p` (1-based) |
| `minus_di(hlc, p)` | `n - p` | `p + 1` (1-based) |
| `plus_di(hlc, p)` | `n - p` | `p + 1` (1-based) |
| `macd(prices, f, s, sig)` | `n - (s + sig - 1)` | `s + sig` (1-based) |
| `bbands(prices, p, *, *, *)` | `n - p + 1` | `p` (1-based) |
| `stoch(hlc, fk, sk, *, sd, *)` | `n - (fk + sk + sd - 2)` | `fk + sk + sd - 1` (1-based) |

When there is insufficient data for even one output value, an empty
`Vector{Float64}` is returned — no error is thrown.

## Adding new indicators

Every TA-Lib indicator follows one of two calling patterns. To add a new
indicator, create a file in `src/indicators/` and add `include` + `export`
entries in `src/TALib.jl`.

### Pattern A — single input array (e.g. SMA, EMA, RSI, ...)

```julia
# src/indicators/sma.jl
function sma(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out       = Vector{Cdouble}(undef, n)
    outBegIdx = Ref{Cint}(0)
    outNBElem = Ref{Cint}(0)
    rc = @ccall TALIB.TA_SMA(
        Cint(0) :: Cint,  Cint(n-1) :: Cint,
        prices  :: Ptr{Cdouble},  Cint(period) :: Cint,
        outBegIdx :: Ref{Cint},  outNBElem :: Ref{Cint},
        out :: Ptr{Cdouble})::Cint
    _check_ret(rc, "TA_SMA")
    return out[1:outNBElem[]]
end
```

### Pattern B — High/Low/Close inputs (e.g. ATR, CCI, ADXR, ...)

```julia
# src/indicators/atr.jl
function atr(high, low, close::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(close)
    out       = Vector{Cdouble}(undef, n)
    outBegIdx = Ref{Cint}(0)
    outNBElem = Ref{Cint}(0)
    rc = @ccall TALIB.TA_ATR(
        Cint(0) :: Cint,  Cint(n-1) :: Cint,
        high :: Ptr{Cdouble},  low :: Ptr{Cdouble},  close :: Ptr{Cdouble},
        Cint(period) :: Cint,
        outBegIdx :: Ref{Cint},  outNBElem :: Ref{Cint},
        out :: Ptr{Cdouble})::Cint
    _check_ret(rc, "TA_ATR")
    return out[1:outNBElem[]]
end
```

Check [`ta_func.h`](https://github.com/TA-Lib/ta-lib/blob/main/include/ta_func.h)
for the exact signature of any indicator you want to add.

## Running the tests

```bash
cd TALib.jl
julia --project=. -e 'using Pkg; Pkg.test()'
```

## License

BSD 2-Clause — see [LICENSE](LICENSE).

This package is an independent wrapper and is not affiliated with or endorsed
by the TA-Lib project. TA-Lib itself is also distributed under the
[BSD license](https://github.com/TA-Lib/ta-lib/blob/main/LICENSE).

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for
guidelines on how to add indicators, run the tests, and submit a pull request.
See [CHANGELOG.md](CHANGELOG.md) for a history of changes.
