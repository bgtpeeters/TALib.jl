"""
    plus_di(high, low, close, period) -> Vector{Float64}

Compute the **Plus Directional Indicator** (+DI) from High, Low, and Close
price series using the given `period`.

+DI measures the strength of upward price movement. When +DI is above
[`minus_di`](@ref), it signals an uptrend. Together with -DI, it is used to
compute the [`adx`](@ref).

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(close) - period`.
Values are in the range [0, 100].
An empty vector is returned when there is insufficient data.

# Example
```julia
high  = Float64[10,11,12,11,10,11,12,13,12,11]
low   = Float64[ 9,10,11,10, 9,10,11,12,11,10]
close = Float64[ 9.5,10.5,11.5,10.5,9.5,10.5,11.5,12.5,11.5,10.5]
plus_di(high, low, close, 3)
```

Wraps `TA_PLUS_DI` from the TA-Lib C library.
"""
function plus_di(
    high  :: AbstractVector{Float64},
    low   :: AbstractVector{Float64},
    close :: AbstractVector{Float64},
    period :: Int
)::Vector{Float64}
    n = length(close)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_PLUS_DI(
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

    _check_ret(rc, "TA_PLUS_DI")
    return out[1:outNBElem[]]
end
