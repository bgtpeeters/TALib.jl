"""
    sma(prices, period) -> Vector{Float64}

Compute the **Simple Moving Average** (SMA) of `prices` using the given
`period`.

A SMA is the unweighted mean of the previous `period` data points. It smooths
out price action and helps identify trends.

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(prices)`.
The first `period - 1` elements are `NaN` due to the lookback period.
The remaining elements correspond to the SMA values.

# Example
```julia
prices = [1.0, 2.0, 3.0, 4.0, 5.0]
sma(prices, 3)   # → [NaN, NaN, 2.0, 3.0, 4.0]
```

Wraps `TA_SMA` from the TA-Lib C library.
"""
function sma(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_SMA(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        prices        :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_SMA")
    return _pad_result(out, outNBElem, n)
end