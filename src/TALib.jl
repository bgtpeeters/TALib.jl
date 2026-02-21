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
    result = wma(prices, 3)

    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
    adx_result      = adx(high, low, close, 3)
    minus_di_result = minus_di(high, low, close, 3)
    plus_di_result  = plus_di(high, low, close, 3)
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
include("indicators/adx.jl")
include("indicators/minus_di.jl")
include("indicators/plus_di.jl")

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
export wma, adx, minus_di, plus_di

end # module TALib
