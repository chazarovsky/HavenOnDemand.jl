using Base.Test
using Requests: json
using HavenOnDemand

try
    set_api_key(ENV["HOD_API_KEY"])
catch ex
    if isa(ex, KeyError)
        info("You have to setup a `HOD_API_KEY` environment variable first.")
    end
end

# `analyze_sentiment`
@test_throws HODException analyze_sentiment()

try
    # needs at least one valid kwarg
    analyze_sentiment(non = :valid, keyword = :arguments)
catch ex
    if isa(ex, HODException)
        response = json(ex.response)
        @test response["error"]  == 4015
        @test response["reason"] == "Missing required parameter(s)"
    end
end

positive_response = analyze_sentiment(text = "I love all zombies!")
@test isa(positive_response, Dict{AbstractString, Any})

@test positive_response["aggregate"]["sentiment"] == "positive"
@test isempty(positive_response["negative"])
@test positive_response["positive"][1]["topic"] == "all zombies"
@test positive_response["positive"][1]["score"] > 0

negative_response = analyze_sentiment(
    text    = "I hate all plants!",    # ...some zombie
    this_is = :ignored    # non valid kwargs are ignored
)

@test negative_response["aggregate"]["sentiment"] == "negative"
@test isempty(negative_response["positive"])
@test negative_response["negative"][1]["topic"] == "all plants"
@test negative_response["negative"][1]["score"] < 0
