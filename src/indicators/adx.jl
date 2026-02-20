"""
    adx(high, low, close, period) -> Vector{Float64}

Compute the **Average Directional Movement Index** (ADX) from High, Low, and
Close price series using the given `period`.

ADX measures the strength of a trend regardless of its direction. Values above
25 typically indicate a strong trend; values below 20 suggest a weak or absent
trend. ADX does not indicate trend direction — use [`plus_di`](@ref) and
[`minus_di`](@ref) for that.

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(close) - 2*(period-1)`.
The ADX requires two successive smoothing passes, so the lookback is
`2 * (period - 1)`. An empty vector is returned when there is insufficient
data.

# Example
```julia
high  = Float64[10,11,12,11,10,11,12,13,12,11]
low   = Float64[ 9,10,11,10, 9,10,11,12,11,10]
close = Float64[ 9.5,10.5,11.5,10.5,9.5,10.5,11.5,12.5,11.5,10.5]
adx(high, low, close, 3)
```

Wraps `TA_ADX` from the TA-Lib C library.
"""
function adx(
    high  :: AbstractVector{Float64},
    low   :: AbstractVector{Float64},
    close :: AbstractVector{Float64},
    period :: Int
)::Vector{Float64}
    n = length(close)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_ADX(
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

    _check_ret(rc, "TA_ADX")
    return out[1:outNBElem[]]
end
