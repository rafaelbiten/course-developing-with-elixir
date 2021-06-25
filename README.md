# Learning Elixir

## [COURSE] Developing with Elixir/OTP
- [x] Go through the [Developing with Elixir/OTP](https://pragmaticstudio.com/courses/elixir/) course.
- [x] Update this `README.md` file when done.

I'm leaving this Repo available mostly for my own reference.

Apart from what is presented in the course, it also contains lots of extra findings around:

- Project setup and managing environments
- Project tooling, ie.: `dialyzer (with dialyxir)`, `credo` and `cortex`
- Some libraries and example usage, ie.: `tesla`, `poison` and `earmark`
- Some experiments with the language, exercises and module reference (under `servy/lib/playground`)
- Testing setup and references (under `/servy/test`)

**And to those starting with or learning Elixir, I can't recommend the course enough!**

## Running the project

To serve:
```elixir
$ iex -S mix
```

To run tests:
```elixir
$ mix test
```

To run all checks (tests, dialyzer and credo):
```elixir
$ mix check_all
```

To automatically run tests related to changed files (with cortex):
```elixir
$ MIX_ENV=test iex -S mix
```