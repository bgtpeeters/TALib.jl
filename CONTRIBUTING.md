# Contributing to TALib.jl

Thank you for your interest in contributing! Every contribution — whether it is
a new indicator, a bug fix, improved documentation, or a test — is welcome.

## Table of contents

- [Getting started](#getting-started)
- [Running the tests](#running-the-tests)
- [Adding a new indicator](#adding-a-new-indicator)
- [Submitting a pull request](#submitting-a-pull-request)
- [Code style](#code-style)

---

## Getting started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/TALib.jl
   cd TALib.jl
   ```
3. **Install the TA-Lib C library** (see [README.md](README.md#prerequisites)).
4. **Activate the project** in Julia:
   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```

---

## Running the tests

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

All tests must pass before you open a pull request. CI runs automatically on
every PR and checks Julia 1.6, 1.10, and the latest stable release.

---

## Adding a new indicator

Every TA-Lib indicator follows one of two calling patterns. Pick the right one,
create a file in `src/indicators/`, then wire it up in `src/TALib.jl`.

### Pattern A — single price input (SMA, EMA, RSI, …)

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

### Pattern B — High / Low / Close inputs (ATR, CCI, ADXR, …)

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

### Wiring it up

In `src/TALib.jl`, add:
```julia
include("indicators/sma.jl")   # one line per new file
export sma                     # one line per new function
```

### Tests

Add a `@testset` block for your indicator in `test/runtests.jl`. At minimum,
test:
- correct output length
- output values are in a sensible range
- insufficient data returns `Float64[]` without error

Check
[`ta_func.h`](https://github.com/TA-Lib/ta-lib/blob/main/include/ta_func.h)
for the exact C signature and lookback formula of any indicator you want to add.

---

## Submitting a pull request

1. Create a branch with a descriptive name:
   ```bash
   git checkout -b add-rsi-indicator
   ```
2. Make your changes and commit them with a clear message.
3. Push to your fork and open a pull request against `main`.
4. Describe what you changed and why in the PR description.
5. CI will run automatically — please ensure all checks pass.

---

## Code style

- Follow existing code formatting (4-space indentation, type annotations on
  public functions).
- Keep each indicator in its own file under `src/indicators/`.
- Public functions should return `Vector{Float64}` and never throw on
  insufficient data (return `Float64[]` instead).
- No external Julia dependencies — only `ccall` / `@ccall`.
