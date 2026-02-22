"""
    dx(high, low, close, period) -> Vector{Float64}

Compute the **Directional Movement Index** (DX) from High, Low, and Close price
series using the given `period`.

DX measures the strength of a trend regardless of its direction. It is the
absolute value of the difference between +DI and -DI divided by their sum.
Values range from 0 to 100, where higher values indicate stronger trends.

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(close)`.
The first `2*(period-1)` elements are `NaN` due to the lookback period.
The remaining elements correspond to the DX values in the range [0, 100].

# Example
```julia
high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
dx(high, low, close, 3)
```

Wraps `TA_DX` from the TA-Lib C library.
"""
function dx(
    high  :: AbstractVector{Float64},
    low   :: AbstractVector{Float64},
    close :: AbstractVector{Float64},
    period :: Int
)::Vector{Float64}
    n = length(close)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_DX(
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

    _check_ret(rc, "TA_DX")
    return _pad_result(out, outNBElem, n)
end