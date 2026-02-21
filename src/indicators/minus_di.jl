"""
    minus_di(high, low, close, period) -> Vector{Float64}

Compute the **Minus Directional Indicator** (-DI) from High, Low, and Close
price series using the given `period`.

-DI measures the strength of downward price movement. When -DI is above
[`plus_di`](@ref), it signals a downtrend. Together with +DI, it is used to
compute the [`adx`](@ref).

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(close)`.
The first `period` elements are `NaN` due to the lookback period.
The remaining elements correspond to the -DI values, in the range [0, 100].

# Example
```julia
high  = Float64[10,11,12,11,10,11,12,13,12,11]
low   = Float64[ 9,10,11,10, 9,10,11,12,11,10]
close = Float64[ 9.5,10.5,11.5,10.5,9.5,10.5,11.5,12.5,11.5,10.5]
minus_di(high, low, close, 3)
```

Wraps `TA_MINUS_DI` from the TA-Lib C library.
"""
function minus_di(
    high  :: AbstractVector{Float64},
    low   :: AbstractVector{Float64},
    close :: AbstractVector{Float64},
    period :: Int
)::Vector{Float64}
    n = length(close)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_MINUS_DI(
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

    _check_ret(rc, "TA_MINUS_DI")
    return _pad_result(out, outNBElem, n)
end
