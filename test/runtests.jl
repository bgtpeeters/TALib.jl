using Test
using TALib

# ---------------------------------------------------------------------------
# Helper: compute WMA reference value by hand.
# For period n, weights are 1, 2, …, n (normalised).
# The last `n` elements of `v` are used.
# ---------------------------------------------------------------------------
function wma_ref(v::Vector{Float64}, n::Int)
    weights = Float64.(1:n)
    window  = v[end-n+1:end]
    return dot(weights, window) / sum(weights)
end

# simple dot product for the helper above
dot(a, b) = sum(a .* b)

# ---------------------------------------------------------------------------
# WMA tests
# ---------------------------------------------------------------------------
@testset "WMA" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    period = 3

    result = wma(prices, period)

    # Output length matches input length
    @test length(result) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period-1]))

    # Each output value matches the reference calculation
    for i in eachindex(result)
        if i >= period
            window = prices[i-period+1:i]
            expected = wma_ref(window, period)
            @test result[i] ≈ expected atol=1e-10
        end
    end

    # Monotonically increasing for a linearly rising input (non-NaN values)
    @test all(diff(result[period:end]) .> 0)

    # Insufficient data → all NaN, no error
    r = wma([1.0, 2.0], 5)
    @test length(r) == 2
    @test all(isnan.(r))

    # Single-element result (period == length)
    r = wma([1.0, 2.0, 3.0], 3)
    @test length(r) == 3
    @test isnan(r[1]) && isnan(r[2])
    @test r[3] ≈ wma_ref([1.0, 2.0, 3.0], 3) atol=1e-10
end

# ---------------------------------------------------------------------------
# Shared HLC test data (20 bars — enough for ADX lookback at period=5)
# ---------------------------------------------------------------------------
const HIGH  = Float64[10,11,12,13,12,11,12,13,14,13,12,13,14,15,14,13,14,15,16,15]
const LOW   = Float64[ 9,10,11,12,11,10,11,12,13,12,11,12,13,14,13,12,13,14,15,14]
const CLOSE = Float64[ 9.5,10.5,11.5,12.5,11.5,10.5,11.5,12.5,13.5,12.5,
                       11.5,12.5,13.5,14.5,13.5,12.5,13.5,14.5,15.5,14.5]
const PERIOD = 5

# ---------------------------------------------------------------------------
# ADX tests
# ---------------------------------------------------------------------------
@testset "ADX" begin
    result = adx(HIGH, LOW, CLOSE, PERIOD)

    # Output length matches input length
    @test length(result) == length(CLOSE)

    # Lookback period is filled with NaN
    lookback = 2 * PERIOD - 1
    @test all(isnan.(result[1:lookback]))

    # ADX is defined in [0, 100] for non-NaN values
    @test all(0.0 .<= result[lookback+1:end] .<= 100.0)

    # Insufficient data → all NaN, no error
    r = adx(HIGH[1:3], LOW[1:3], CLOSE[1:3], PERIOD)
    @test length(r) == 3
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# MINUS_DI tests
# ---------------------------------------------------------------------------
@testset "MINUS_DI" begin
    result = minus_di(HIGH, LOW, CLOSE, PERIOD)

    # Output length matches input length
    @test length(result) == length(CLOSE)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:PERIOD]))

    # -DI is defined in [0, 100] for non-NaN values
    @test all(0.0 .<= result[PERIOD+1:end] .<= 100.0)

    # Insufficient data → all NaN, no error
    r = minus_di(HIGH[1:2], LOW[1:2], CLOSE[1:2], PERIOD)
    @test length(r) == 2
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# PLUS_DI tests
# ---------------------------------------------------------------------------
@testset "PLUS_DI" begin
    result = plus_di(HIGH, LOW, CLOSE, PERIOD)

    # Output length matches input length
    @test length(result) == length(CLOSE)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:PERIOD]))

    # +DI is defined in [0, 100] for non-NaN values
    @test all(0.0 .<= result[PERIOD+1:end] .<= 100.0)

    # Insufficient data → all NaN, no error
    r = plus_di(HIGH[1:2], LOW[1:2], CLOSE[1:2], PERIOD)
    @test length(r) == 2
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# ADX / MINUS_DI / PLUS_DI consistency: run all three on the same data
# and verify they are mutually consistent in length.
# ---------------------------------------------------------------------------
@testset "Directional indicators consistency" begin
    adx_r      = adx(HIGH, LOW, CLOSE, PERIOD)
    minus_di_r = minus_di(HIGH, LOW, CLOSE, PERIOD)
    plus_di_r  = plus_di(HIGH, LOW, CLOSE, PERIOD)

    # All three produce output with the same length as input
    @test length(adx_r) == length(CLOSE)
    @test length(minus_di_r) == length(CLOSE)
    @test length(plus_di_r) == length(CLOSE)

    # ADX has a longer lookback than +DI / -DI, so it has more NaN values
    adx_nan_count = sum(isnan.(adx_r))
    di_nan_count = sum(isnan.(minus_di_r))
    @test adx_nan_count > di_nan_count
    @test sum(isnan.(plus_di_r)) == di_nan_count
end

# ---------------------------------------------------------------------------
# SMA tests
# ---------------------------------------------------------------------------
@testset "SMA" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    period = 3

    result = sma(prices, period)

    # Output length matches input length
    @test length(result) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period-1]))

    # Each output value matches expected SMA calculation
    for i in eachindex(result)
        if i >= period
            window = prices[i-period+1:i]
            expected = sum(window) / period
            @test result[i] ≈ expected atol=1e-10
        end
    end

    # Insufficient data → all NaN, no error
    r = sma([1.0, 2.0], 5)
    @test length(r) == 2
    @test all(isnan.(r))

    # Single-element result (period == length)
    r = sma([1.0, 2.0, 3.0], 3)
    @test length(r) == 3
    @test isnan(r[1]) && isnan(r[2])
    @test r[3] ≈ 2.0 atol=1e-10
end

# ---------------------------------------------------------------------------
# EMA tests
# ---------------------------------------------------------------------------
@testset "EMA" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    period = 3

    result = ema(prices, period)

    # Output length matches input length
    @test length(result) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period-1]))

    # First valid EMA should equal first valid SMA
    @test result[period] ≈ sma(prices, period)[period] atol=1e-10

    # EMA values should be different from SMA for subsequent periods (usually)
    # Note: For linearly increasing data, EMA and SMA can be equal
    # So we just test that we get valid non-NaN values
    @test !isnan(result[period+1])

    # Insufficient data → all NaN, no error
    r = ema([1.0, 2.0], 5)
    @test length(r) == 2
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# RSI tests
# ---------------------------------------------------------------------------
@testset "RSI" begin
    prices = [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.12]
    period = 5

    result = rsi(prices, period)

    # Output length matches input length
    @test length(result) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period]))

    # RSI is defined in [0, 100] for non-NaN values
    @test all(0.0 .<= result[period+1:end] .<= 100.0)

    # Insufficient data → all NaN, no error
    r = rsi([1.0, 2.0, 3.0], 5)
    @test length(r) == 3
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# ROC tests
# ---------------------------------------------------------------------------
@testset "ROC" begin
    prices = [10.0, 11.0, 12.0, 13.0, 14.0, 15.0]
    period = 2

    result = roc(prices, period)

    # Output length matches input length
    @test length(result) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period]))

    # ROC calculation: ((price / price[period ago]) - 1) * 100
    # For prices[3] = 12.0, prices[1] = 10.0: ((12/10) - 1) * 100 = 20
    @test result[3] ≈ 20.0 atol=1e-10

    # Insufficient data → all NaN, no error
    r = roc([1.0], 2)
    @test length(r) == 1
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# ATR tests
# ---------------------------------------------------------------------------
@testset "ATR" begin
    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
    period = 3

    result = atr(high, low, close, period)

    # Output length matches input length
    @test length(result) == length(close)

    # Lookback period is filled with NaN
    @test all(isnan.(result[1:period]))

    # ATR values should be positive
    @test all(result[period+1:end] .> 0.0)

    # Insufficient data → all NaN, no error
    r = atr(high[1:2], low[1:2], close[1:2], period)
    @test length(r) == 2
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# DX tests
# ---------------------------------------------------------------------------
@testset "DX" begin
    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
    period = 3

    result = dx(high, low, close, period)

    # Output length matches input length
    @test length(result) == length(close)

    # Lookback period is filled with NaN
    # For DX with period=3, the lookback is 3 bars
    lookback = 3
    @test all(isnan.(result[1:lookback]))

    # DX is defined in [0, 100] for non-NaN values
    @test all(0.0 .<= result[lookback+1:end] .<= 100.0)

    # Insufficient data → all NaN, no error
    r = dx(high[1:2], low[1:2], close[1:2], period)
    @test length(r) == 2
    @test all(isnan.(r))
end

# ---------------------------------------------------------------------------
# MACD tests
# ---------------------------------------------------------------------------
@testset "MACD" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    fast_period = 3
    slow_period = 5
    signal_period = 2

    macd_line, signal_line, histogram = macd(prices, fast_period, slow_period, signal_period)

    # All outputs have same length as input
    @test length(macd_line) == length(signal_line) == length(histogram) == length(prices)

    # Lookback period is filled with NaN
    # For MACD with fast=3, slow=5, signal=2, the lookback is 5 bars
    lookback = 5
    @test all(isnan.(macd_line[1:lookback]))
    @test all(isnan.(signal_line[1:lookback]))
    @test all(isnan.(histogram[1:lookback]))

    # Histogram should equal MACD line minus signal line (for non-NaN values)
    valid_indices = findall(.!isnan.(macd_line))
    expected_hist = macd_line[valid_indices] .- signal_line[valid_indices]
    @test all(abs.(histogram[valid_indices] .- expected_hist) .< 1e-10)

    # Insufficient data → all NaN, no error
    r_macd, r_signal, r_hist = macd([1.0, 2.0], fast_period, slow_period, signal_period)
    @test length(r_macd) == length(r_signal) == length(r_hist) == 2
    @test all(isnan.(r_macd)) && all(isnan.(r_signal)) && all(isnan.(r_hist))
end

# ---------------------------------------------------------------------------
# BBANDS tests
# ---------------------------------------------------------------------------
@testset "BBANDS" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    period = 3
    nb_dev_up = 2.0
    nb_dev_dn = 2.0
    ma_type = 0  # SMA

    upper, middle, lower = bbands(prices, period, nb_dev_up, nb_dev_dn, ma_type)

    # All outputs have same length as input
    @test length(upper) == length(middle) == length(lower) == length(prices)

    # Lookback period is filled with NaN
    @test all(isnan.(upper[1:period-1]))
    @test all(isnan.(middle[1:period-1]))
    @test all(isnan.(lower[1:period-1]))

    # Middle band should equal SMA
    expected_sma = sma(prices, period)
    @test all(abs.(middle[period:end] .- expected_sma[period:end]) .< 1e-10)

    # Upper band should be above middle band, lower band below (for non-NaN values)
    valid_indices = findall(.!isnan.(upper))
    @test all(upper[valid_indices] .> middle[valid_indices])
    @test all(lower[valid_indices] .< middle[valid_indices])

    # Insufficient data → all NaN, no error
    r_upper, r_middle, r_lower = bbands([1.0, 2.0], period, nb_dev_up, nb_dev_dn, ma_type)
    @test length(r_upper) == length(r_middle) == length(r_lower) == 2
    @test all(isnan.(r_upper)) && all(isnan.(r_middle)) && all(isnan.(r_lower))
end

# ---------------------------------------------------------------------------
# STOCH tests
# ---------------------------------------------------------------------------
@testset "STOCH" begin
    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]
    fastk_period = 5
    slowk_period = 3
    slowk_ma = 0
    slowd_period = 3
    slowd_ma = 0

    slowk, slowd = stoch(high, low, close, fastk_period, slowk_period, slowk_ma, slowd_period, slowd_ma)

    # All outputs have same length as input
    @test length(slowk) == length(slowd) == length(close)

    # Stochastic values should be in [0, 100] range for non-NaN values
    valid_indices = findall(.!isnan.(slowk))
    @test all(0.0 .<= slowk[valid_indices] .<= 100.0)
    @test all(0.0 .<= slowd[valid_indices] .<= 100.0)

    # Insufficient data → all NaN, no error
    r_slowk, r_slowd = stoch(high[1:2], low[1:2], close[1:2], fastk_period, slowk_period, slowk_ma, slowd_period, slowd_ma)
    @test length(r_slowk) == length(r_slowd) == 2
    @test all(isnan.(r_slowk)) && all(isnan.(r_slowd))
end

# ---------------------------------------------------------------------------
# All indicators consistency test
# ---------------------------------------------------------------------------
@testset "All indicators consistency" begin
    prices = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    high  = [10.0, 11.0, 12.0, 11.0, 10.0, 11.0, 12.0, 13.0, 12.0, 11.0]
    low   = [ 9.0, 10.0, 11.0, 10.0,  9.0, 10.0, 11.0, 12.0, 11.0, 10.0]
    close = [ 9.5, 10.5, 11.5, 10.5,  9.5, 10.5, 11.5, 12.5, 11.5, 10.5]

    # Test that all indicators return arrays of the correct length
    sma_result = sma(prices, 3)
    ema_result = ema(prices, 3)
    rsi_result = rsi(prices, 5)
    roc_result = roc(prices, 2)
    atr_result = atr(high, low, close, 3)
    dx_result = dx(high, low, close, 3)
    macd_line, macd_signal, macd_hist = macd(prices, 3, 5, 2)
    upper, middle, lower = bbands(prices, 3, 2.0, 2.0, 0)
    slowk, slowd = stoch(high, low, close, 5, 3, 0, 3, 0)

    @test length(sma_result) == length(prices)
    @test length(ema_result) == length(prices)
    @test length(rsi_result) == length(prices)
    @test length(roc_result) == length(prices)
    @test length(atr_result) == length(close)
    @test length(dx_result) == length(close)
    @test length(macd_line) == length(macd_signal) == length(macd_hist) == length(prices)
    @test length(upper) == length(middle) == length(lower) == length(prices)
    @test length(slowk) == length(slowd) == length(close)
end
