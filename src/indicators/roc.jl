"""
    roc(prices, period) -> Vector{Float64}

Compute the **Rate of Change** (ROC) of `prices` using the given `period`.

ROC measures the percentage change in price over the specified period.
It is calculated as: `((price / price[period ago]) - 1) * 100`.

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `period::Int`: number of bars (1–100000).

# Returns
A `Vector{Float64}` of length `length(prices)`.
The first `period` elements are `NaN` due to the lookback period.
The remaining elements correspond to the ROC values (percentage change).

# Example
```julia
prices = [10.0, 11.0, 12.0, 13.0, 14.0]
roc(prices, 2)   # → [NaN, NaN, 9.0909..., 8.3333..., 7.6923...]
```

Wraps `TA_ROC` from the TA-Lib C library.
"""
function roc(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_ROC(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        prices        :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_ROC")
    return _pad_result(out, outNBElem, n)
end