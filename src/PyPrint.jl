"""
    PyPrint

Provides [`pprint`](@ref) and [`@pprint`](@ref)
for Python-style pretty-printing.
"""
module PyPrint

export pprint, @pprint

"""
    prepr(io::IO, x)

Return the human-readable string representation of `x`, like in the REPL.

Suppress quotes around strings and Unicode codepoint printing of characters.
For additional information and customization, see:
- [https://stackoverflow.com/questions/40788316/40794864#40794864]
  (https://stackoverflow.com/questions/40788316/40794864#40794864)
- [https://docs.julialang.org/en/v1/base/io-network/#Base.IOContext]
  (https://docs.julialang.org/en/v1/base/io-network/#Base.IOContext)
"""
prepr(io::IO, x) = repr(
    "text/plain",
    x;
    context=IOContext(
        io,
        :limit => true,
        :displaysize => (11, 80),
    )
)
prepr(_::IO, x::AbstractString) = x
prepr(_::IO, x::AbstractChar) = x

"""
    pprint([io::IO], x...)

Pretty-print `x`, joining multiple arguments with a space like in Python.

Uses [`prepr`](@ref) to get the string representation of `x`.
"""
pprint(io::IO, x...) = print(
    join(prepr(io, y) for x in zip(x, " "^length(x)) for y in x), "\n"
)
pprint(xs...) = pprint(stdout, xs...)

"""
    @pprint exs...

Print expressions along with their pretty-printed results from [`prepr`](@ref).

Copied from the implementation of [`@show`](@ref).
"""
macro pprint(exs...)
    blk = Expr(:block)
    for ex in exs
        push!(
            blk.args,
            :(println(
                $(sprint(show, ex) *" = "),
                prepr(stdout, begin local value = $(esc(ex)) end)
            ))
        )
    end
    isempty(exs) || push!(blk.args, :value)
    return blk
end

end
