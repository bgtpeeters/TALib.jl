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

    # Output length: n - period + 1
    @test length(result) == length(prices) - period + 1

    # Each output value matches the reference calculation
    for i in eachindex(result)
        window = prices[i:i+period-1]
        expected = wma_ref(window, period)
        @test result[i] ≈ expected atol=1e-10
    end

    # Monotonically increasing for a linearly rising input
    @test all(diff(result) .> 0)

    # Insufficient data → empty result, no error
    @test wma([1.0, 2.0], 5) == Float64[]

    # Single-element result (period == length)
    r = wma([1.0, 2.0, 3.0], 3)
    @test length(r) == 1
    @test r[1] ≈ wma_ref([1.0, 2.0, 3.0], 3) atol=1e-10
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

    # Must produce some output
    @test length(result) > 0

    # ADX lookback = 2*(period-1); output length = n - 2*(period-1)
    expected_len = length(CLOSE) - 2 * (PERIOD - 1)
    @test length(result) == expected_len

    # ADX is defined in [0, 100]
    @test all(0.0 .<= result .<= 100.0)

    # Insufficient data → empty, no error
    @test adx(HIGH[1:3], LOW[1:3], CLOSE[1:3], PERIOD) == Float64[]
end

# ---------------------------------------------------------------------------
# MINUS_DI tests
# ---------------------------------------------------------------------------
@testset "MINUS_DI" begin
    result = minus_di(HIGH, LOW, CLOSE, PERIOD)

    @test length(result) > 0

    # Lookback for MINUS_DI = period; output length = n - period
    @test length(result) == length(CLOSE) - PERIOD

    # -DI is defined in [0, 100]
    @test all(0.0 .<= result .<= 100.0)

    # Insufficient data → empty, no error
    @test minus_di(HIGH[1:2], LOW[1:2], CLOSE[1:2], PERIOD) == Float64[]
end

# ---------------------------------------------------------------------------
# PLUS_DI tests
# ---------------------------------------------------------------------------
@testset "PLUS_DI" begin
    result = plus_di(HIGH, LOW, CLOSE, PERIOD)

    @test length(result) > 0

    # Lookback for PLUS_DI = period; output length = n - period
    @test length(result) == length(CLOSE) - PERIOD

    # +DI is defined in [0, 100]
    @test all(0.0 .<= result .<= 100.0)

    # Insufficient data → empty, no error
    @test plus_di(HIGH[1:2], LOW[1:2], CLOSE[1:2], PERIOD) == Float64[]
end

# ---------------------------------------------------------------------------
# ADX / MINUS_DI / PLUS_DI consistency: run all three on the same data
# and verify they are mutually consistent in length.
# ---------------------------------------------------------------------------
@testset "Directional indicators consistency" begin
    adx_r      = adx(HIGH, LOW, CLOSE, PERIOD)
    minus_di_r = minus_di(HIGH, LOW, CLOSE, PERIOD)
    plus_di_r  = plus_di(HIGH, LOW, CLOSE, PERIOD)

    # All three produce output
    @test length(adx_r)      > 0
    @test length(minus_di_r) > 0
    @test length(plus_di_r)  > 0

    # ADX has a longer lookback than +DI / -DI, so it is strictly shorter
    @test length(adx_r) < length(minus_di_r)
    @test length(minus_di_r) == length(plus_di_r)
end
