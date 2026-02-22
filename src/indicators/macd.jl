"""
    macd(prices, fast_period, slow_period, signal_period) -> (macd, signal, hist)

Compute the **Moving Average Convergence Divergence** (MACD) of `prices` using
the given periods.

MACD is a trend-following momentum indicator that shows the relationship between
two moving averages of a security's price. It consists of:
- MACD line: difference between fast and slow EMAs
- Signal line: EMA of the MACD line
- Histogram: difference between MACD line and signal line

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `fast_period::Int`: number of bars for fast EMA (2–100000).
- `slow_period::Int`: number of bars for slow EMA (2–100000).
- `signal_period::Int`: number of bars for signal line (1–100000).

# Returns
A tuple of three `Vector{Float64}` arrays, each of length `length(prices)`:
- `macd`: MACD line values
- `signal`: signal line values  
- `hist`: histogram values (macd - signal)

The first `slow_period + signal_period - 1` elements are `NaN` due to the lookback
period.

# Example
```julia
prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
macd_line, signal_line, histogram = macd(prices, 12, 26, 9)
```

Wraps `TA_MACD` from the TA-Lib C library.
"""
function macd(
    prices::AbstractVector{Float64},
    fast_period::Int,
    slow_period::Int,
    signal_period::Int
)::Tuple{Vector{Float64}, Vector{Float64}, Vector{Float64}}
    n = length(prices)
    
    # Output arrays for MACD, signal, and histogram
    outMACD        = Vector{Cdouble}(undef, n)
    outMACDSignal  = Vector{Cdouble}(undef, n)
    outMACDHist    = Vector{Cdouble}(undef, n)
    
    outBegIdx      = Ref{Cint}(0)
    outNBElem      = Ref{Cint}(0)

    rc = @ccall TALIB.TA_MACD(
        Cint(0)           :: Cint,
        Cint(n - 1)       :: Cint,
        prices            :: Ptr{Cdouble},
        Cint(fast_period) :: Cint,
        Cint(slow_period) :: Cint,
        Cint(signal_period) :: Cint,
        outBegIdx         :: Ref{Cint},
        outNBElem         :: Ref{Cint},
        outMACD           :: Ptr{Cdouble},
        outMACDSignal     :: Ptr{Cdouble},
        outMACDHist       :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_MACD")
    
    return (
        _pad_result(outMACD, outNBElem, n),
        _pad_result(outMACDSignal, outNBElem, n),
        _pad_result(outMACDHist, outNBElem, n)
    )
end