"""
    TALib

Julia wrapper around the TA-Lib C library (https://ta-lib.org/).

Provides direct `ccall`-based bindings to TA-Lib technical analysis indicators.
The library must be installed on the system before this package can be used.

# Installation of TA-Lib (Linux)

    # Debian/Ubuntu via .deb package (recommended):
    curl -LO https://github.com/ta-lib/ta-lib/releases/download/v0.6.4/ta-lib_0.6.4_amd64.deb
    sudo dpkg -i ta-lib_0.6.4_amd64.deb

    # Or build from source:
    ./configure && make && sudo make install

# Quick start

    using TALib

    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    wma_result = wma(prices, 3)
    sma_result = sma(prices, 3)
    ema_result = ema(prices, 3)
    rsi_result = rsi(prices, 5)
    roc_result = roc(prices, 2)

    # MACD returns (macd_line, signal_line, histogram)
    macd_line, macd_signal, macd_hist = macd(prices, 12, 26, 9)

    # BBANDS returns (upper_band, middle_band, lower_band)
    upper_band, middle_band, lower_band = bbands(prices, 20, 2.0, 2.0, 0)

    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
    atr_result      = atr(high, low, close, 3)
    dx_result       = dx(high, low, close, 3)
    adx_result      = adx(high, low, close, 3)
    minus_di_result = minus_di(high, low, close, 3)
    plus_di_result  = plus_di(high, low, close, 3)

    # STOCH returns (slowk, slowd)
    slowk, slowd = stoch(high, low, close, 5, 3, 0, 3, 0)
"""
module TALib

# ---------------------------------------------------------------------------
# Library name — resolved by the dynamic linker at runtime.
# On Linux: libta-lib.so (installed via dpkg or build from source)
# ---------------------------------------------------------------------------
const TALIB = "libta-lib"

# ---------------------------------------------------------------------------
# Lifecycle: TA_Initialize must be called once before any indicator function.
# TA_Shutdown is registered with atexit so it is called on process exit.
# ---------------------------------------------------------------------------
function __init__()
    rc = @ccall TALIB.TA_Initialize()::Cint
    rc == 0 || error(
        "TALib: TA_Initialize() failed with return code $rc. " *
        "Is the TA-Lib C library installed? " *
        "See https://ta-lib.org/install for installation instructions."
    )
    atexit() do
        @ccall TALIB.TA_Shutdown()::Cvoid
    end
end

# ---------------------------------------------------------------------------
# Internal helper: raise a Julia error on a non-zero TA_RetCode.
# TA_RetCode == 0 means TA_SUCCESS.
# ---------------------------------------------------------------------------
function _check_ret(rc::Cint, fname::String)
    rc == 0 && return
    error("TALib: $fname returned error code $rc")
end

# ---------------------------------------------------------------------------
# Internal helper: pad the result with NaN values for the lookback period.
# This ensures that the output array has the same length as the input data.
# ---------------------------------------------------------------------------
function _pad_result(out::Vector{Cdouble}, outNBElem::Ref{Cint}, n::Int)
    result = Vector{Float64}(undef, n)
    fill!(result, NaN)
    result[(n - outNBElem[] + 1):end] = out[1:outNBElem[]]
    return result
end

# ---------------------------------------------------------------------------
# Indicator implementations
# ---------------------------------------------------------------------------
include("indicators/wma.jl")
include("indicators/sma.jl")
include("indicators/ema.jl")
include("indicators/rsi.jl")
include("indicators/roc.jl")
include("indicators/atr.jl")
include("indicators/dx.jl")
include("indicators/macd.jl")
include("indicators/bbands.jl")
include("indicators/stoch.jl")
include("indicators/adx.jl")
include("indicators/minus_di.jl")
include("indicators/plus_di.jl")

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
export wma, sma, ema, rsi, roc, atr, dx, macd, bbands, stoch, adx, minus_di, plus_di

end # module TALib
