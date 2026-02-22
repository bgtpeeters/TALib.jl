"""
    stoch(high, low, close, fastk_period, slowk_period, slowk_ma, slowd_period, slowd_ma) -> (slowk, slowd)

Compute the **Stochastic Oscillator** from High, Low, and Close price series
using the given parameters.

The Stochastic Oscillator compares a security's closing price to its price range
over a given period. It consists of two lines:
- %K (slowk): shows the location of the close relative to the high-low range
- %D (slowd): moving average of %K

# Arguments
- `high::AbstractVector{Float64}`: high prices.
- `low::AbstractVector{Float64}`: low prices.
- `close::AbstractVector{Float64}`: closing prices.
  All three vectors must have the same length.
- `fastk_period::Int`: time period for the %K calculation (1–100000).
- `slowk_period::Int`: smoothing period for %K (1–100000).
- `slowk_ma::Int`: type of moving average for %K (0=SMA, 1=EMA, etc.).
- `slowd_period::Int`: smoothing period for %D (1–100000).
- `slowd_ma::Int`: type of moving average for %D (0=SMA, 1=EMA, etc.).

# Returns
A tuple of two `Vector{Float64}` arrays, each of length `length(close)`:
- `slowk`: %K values
- `slowd`: %D values

The first elements are `NaN` due to the lookback period.

# Example
```julia
high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
slowk, slowd = stoch(high, low, close, 5, 3, 0, 3, 0)
```

Wraps `TA_STOCH` from the TA-Lib C library.
"""
function stoch(
    high::AbstractVector{Float64},
    low::AbstractVector{Float64},
    close::AbstractVector{Float64},
    fastk_period::Int,
    slowk_period::Int,
    slowk_ma::Int,
    slowd_period::Int,
    slowd_ma::Int
)::Tuple{Vector{Float64}, Vector{Float64}}
    n = length(close)
    
    # Output arrays for slow %K and slow %D
    outSlowK    = Vector{Cdouble}(undef, n)
    outSlowD    = Vector{Cdouble}(undef, n)
    
    outBegIdx   = Ref{Cint}(0)
    outNBElem   = Ref{Cint}(0)

    rc = @ccall TALIB.TA_STOCH(
        Cint(0)           :: Cint,
        Cint(n - 1)       :: Cint,
        high              :: Ptr{Cdouble},
        low               :: Ptr{Cdouble},
        close             :: Ptr{Cdouble},
        Cint(fastk_period) :: Cint,
        Cint(slowk_period) :: Cint,
        Cint(slowk_ma)     :: Cint,
        Cint(slowd_period) :: Cint,
        Cint(slowd_ma)     :: Cint,
        outBegIdx         :: Ref{Cint},
        outNBElem         :: Ref{Cint},
        outSlowK          :: Ptr{Cdouble},
        outSlowD          :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_STOCH")
    
    return (
        _pad_result(outSlowK, outNBElem, n),
        _pad_result(outSlowD, outNBElem, n)
    )
end