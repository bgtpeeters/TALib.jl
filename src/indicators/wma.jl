"""
    wma(prices, period) -> Vector{Float64}

Compute the **Weighted Moving Average** (WMA) of `prices` using the given
`period`.

A WMA assigns linearly increasing weights to successive data points, giving
the most recent price the highest weight. For a period of `n`, the weights
are `1, 2, …, n` (normalised so they sum to 1).

# Arguments
- `prices::AbstractVector{Float64}`: input price series (e.g. closing prices).
- `period::Int`: number of bars (2–100000).

# Returns
A `Vector{Float64}` of length `length(prices) - period + 1`.
The first element corresponds to input index `period` (1-based).
An empty vector is returned when `period > length(prices)`.

# Example
```julia
prices = [1.0, 2.0, 3.0, 4.0, 5.0]
wma(prices, 3)   # → [2.3333..., 3.3333..., 4.3333...]
```

Wraps `TA_WMA` from the TA-Lib C library.
"""
function wma(prices::AbstractVector{Float64}, period::Int)::Vector{Float64}
    n = length(prices)
    out        = Vector{Cdouble}(undef, n)
    outBegIdx  = Ref{Cint}(0)
    outNBElem  = Ref{Cint}(0)

    rc = @ccall TALIB.TA_WMA(
        Cint(0)       :: Cint,
        Cint(n - 1)   :: Cint,
        prices        :: Ptr{Cdouble},
        Cint(period)  :: Cint,
        outBegIdx     :: Ref{Cint},
        outNBElem     :: Ref{Cint},
        out           :: Ptr{Cdouble}
    )::Cint

    _check_ret(rc, "TA_WMA")
    return out[1:outNBElem[]]
end
