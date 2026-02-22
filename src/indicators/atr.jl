"""
    atr(high, low, close, period) -> Vector{Float64}

Compute the **Average True Range** (ATR) from High, Low, and Close price series
using the given `period`.

ATR measures market volatility by decomposing the entire range of an asset price
for that period. It accounts for gaps and limit moves, providing a more
comprehensive measure of volatility than simple range calculations.

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `period::Int`: number of bars (1–100000).

# Returns
A `Vector{Float64}` of length `length(close)`.
The first `period` elements are `NaN` due to the lookback period.
The remaining elements correspond to the ATR values.

# Example
```julia
high  = [10.0, 11.0, 12.0, 11.0, 10.0]
low   = [ 9.0, 10.0, 11.0, 10.0,  9.0]
close = [ 9.5, 10.5, 11.5, 10.5,  9.5]
atr(high, low, close, 3)
```

Wraps `TA_ATR` from the TA-Lib C library.
"""
function atr(
    high  :: AbstractVector{Float64},
    low   :: AbstractVector{Float64},
    close :: AbstractVector{Float64},
    period :: Int
)::Vector{Float64}
    n = length(close)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_ATR(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        high          :: Ptr{Cdouble},
        low           :: Ptr{Cdouble},
        close         :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_ATR")
    return _pad_result(out, outNBElem, n)
end