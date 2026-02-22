"""
    ema(prices, period) -> Vector{Float64}

Compute the **Exponential Moving Average** (EMA) of `prices` using the given
`period`.

An EMA applies more weight to recent prices, making it more responsive to new
information compared to SMA. The weighting factor is `2/(period+1)`.

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(prices)`.
The first `period - 1` elements are `NaN` due to the lookback period.
The remaining elements correspond to the EMA values.

# Example
```julia
prices = [1.0, 2.0, 3.0, 4.0, 5.0]
ema(prices, 3)   # → [NaN, NaN, 2.0, 2.8333..., 3.6111...]
```

Wraps `TA_EMA` from the TA-Lib C library.
"""
function ema(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_EMA(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        prices        :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_EMA")
    return _pad_result(out, outNBElem, n)
end