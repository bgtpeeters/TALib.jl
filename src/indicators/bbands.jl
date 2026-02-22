"""
    bbands(prices, period, nb_dev_up, nb_dev_dn, ma_type) -> (upper, middle, lower)

Compute **Bollinger Bands** for `prices` using the given parameters.

Bollinger Bands consist of a middle band (typically a moving average) and two
outer bands that are standard deviations away from the middle band. They help
identify overbought/oversold conditions and potential breakouts.

# Arguments
- `prices::AbstractVector{Float64}`: input price series.
- `period::Int`: number of bars for moving average (2–100000).
- `nb_dev_up::Float64`: number of standard deviations for upper band.
- `nb_dev_dn::Float64`: number of standard deviations for lower band.
- `ma_type::Cint`: type of moving average (0=SMA, 1=EMA, etc.).

# Returns
A tuple of three `Vector{Float64}` arrays, each of length `length(prices)`:
- `upper`: upper band values
- `middle`: middle band (moving average) values
- `lower`: lower band values

The first `period - 1` elements are `NaN` due to the lookback period.

# Example
```julia
prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
upper, middle, lower = bbands(prices, 5, 2.0, 2.0, 0)  # SMA-based bands
```

Wraps `TA_BBANDS` from the TA-Lib C library.
"""
function bbands(
    prices::AbstractVector{Float64},
    period::Int,
    nb_dev_up::Float64,
    nb_dev_dn::Float64,
    ma_type::Int
)::Tuple{Vector{Float64}, Vector{Float64}, Vector{Float64}}
    n = length(prices)
    
    # Output arrays for upper, middle, and lower bands
    outUpperBand    = Vector{Cdouble}(undef, n)
    outMiddleBand   = Vector{Cdouble}(undef, n)
    outLowerBand    = Vector{Cdouble}(undef, n)
    
    outBegIdx       = Ref{Cint}(0)
    outNBElem       = Ref{Cint}(0)

    rc = @ccall TALIB.TA_BBANDS(
        Cint(0)           :: Cint,
        Cint(n - 1)       :: Cint,
        prices            :: Ptr{Cdouble},
        Cint(period)      :: Cint,
        Cdouble(nb_dev_up) :: Cdouble,
        Cdouble(nb_dev_dn) :: Cdouble,
        Cint(ma_type)     :: Cint,
        outBegIdx         :: Ref{Cint},
        outNBElem         :: Ref{Cint},
        outUpperBand      :: Ptr{Cdouble},
        outMiddleBand     :: Ptr{Cdouble},
        outLowerBand      :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_BBANDS")
    
    return (
        _pad_result(outUpperBand, outNBElem, n),
        _pad_result(outMiddleBand, outNBElem, n),
        _pad_result(outLowerBand, outNBElem, n)
    )
end