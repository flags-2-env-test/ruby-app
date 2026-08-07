# Ruby consumer of oresoftware/flags-2-env.
#
# Asserts the contract in EXPECTED.md. Raises on the first disagreement, which
# is what makes `docker run` the whole test.

REPO = File.expand_path("..", __dir__)
VENDOR = File.join(REPO, ".vendor/.zed/oresoftware/flags-2-env")

# The Ruby client dlloads its native library at require time, reading
# FLAGS2ENV_NATIVE_LIB. Setting it after the require would be too late, so the
# Dockerfile sets it in the environment and this only fills in a default for
# anyone running the file outside the container.
ENV["FLAGS2ENV_NATIVE_LIB"] ||= File.join(VENDOR, "build/libflags2env.so")

require File.join(VENDOR, "clients/ruby/lib")

CONFIG = File.join(REPO, ".cli-flags.toml")

DEFAULTS = { "PORT" => "3000", "DEBUG" => "false", "APP_ENV" => "development", "COLOR" => "true" }.freeze
OVERRIDDEN = { "PORT" => "8181", "DEBUG" => "true", "APP_ENV" => "production", "COLOR" => "true" }.freeze

CASES = [
  ["defaults",     [],                                                             DEFAULTS],
  ["long flags",   ["--port", "8181", "--debug=t", "--mode", "production"],        OVERRIDDEN],
  ["short flags",  ["-p", "8181", "-d", "1", "--env", "production"],               OVERRIDDEN],
  ["long aliases", ["--listen-port", "8181", "--debug", "1", "--mode", "production"], OVERRIDDEN],
  ["joined by =",  ["--port=8181", "--debug=yes", "--mode=production"],            OVERRIDDEN],
  ["negation",     ["--no-color"],                                                 DEFAULTS.merge("COLOR" => "false")]
].freeze

failures = 0

CASES.each do |label, flags, expected|
  got = Flags2Env.parse(["demo", *flags], config_path: CONFIG)
  ok = got == expected
  failures += 1 unless ok
  puts format("%-4s %-13s demo %s", ok ? "ok" : "FAIL", label, flags.join(" "))
  expected.keys.sort.each { |key| puts "       #{key}=#{got.fetch(key, '<missing>')}" }
  next if ok

  warn "       expected #{expected.inspect}"
  warn "       got      #{got.inspect}"
end

if failures.positive?
  warn "\nruby-app: #{failures} of #{CASES.length} cases disagree with the contract"
  exit 1
end

puts "\nruby-app OK: #{CASES.length} cases, via Fiddle into oresoftware/flags-2-env"
