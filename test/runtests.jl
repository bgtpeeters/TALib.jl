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
