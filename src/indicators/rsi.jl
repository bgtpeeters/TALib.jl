"""
    rsi(prices, period) -> Vector{Float64}

Compute the **Relative Strength Index** (RSI) of `prices` using the given
`period`.

RSI is a momentum oscillator that measures the speed and change of price
movements. It oscillates between 0 and 100. Typically, RSI values above 70
indicate overbought conditions, while values below 30 indicate oversold
conditions.

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(prices)`.
The first `period` elements are `NaN` due to the lookback period.
The remaining elements correspond to the RSI values in the range [0, 100].

# Example
```julia
prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83]
rsi(prices, 5)   # → [NaN, NaN, NaN, NaN, NaN, 60.0]
```

Wraps `TA_RSI` from the TA-Lib C library.
"""
function rsi(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_RSI(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        prices        :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_RSI")
    return _pad_result(out, outNBElem, n)
end