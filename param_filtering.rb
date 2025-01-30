require 'benchmark'
require 'benchmark/ips'
require 'active_support/parameter_filter'

original_filters = [
  :first_name,
  :last_name,
  :full_name,
  :phone,
  :email,
  :password,
  :password_confirmation,
  :ssn,
  :social_security_number,
  :masked_social_security_number,
  :ein,
  :tin,
  :nacha_file,
  :account_number,
  :routing_number,
  :bank_account_number,
  :bank_routing_number,
  :pin,
  :order_request_payload,
]

reduced_filters = [
:phone,
:email,
:passw,
:ssn,
:social_security_number,
:ein,
:tin,
:nacha_file,
:account_number,
:routing_number,
:pin,
:order_request_payload,
]

name_regex = /(?:first|last|full)_name/i
name_strings = [:first_name, :last_name, :full_name]

original = ActiveSupport::ParameterFilter.new(original_filters)
reduced_regex = ActiveSupport::ParameterFilter.new([name_regex] + reduced_filters)
reduced_strings = ActiveSupport::ParameterFilter.new(name_strings + reduced_filters)

# we don't want a match as this simulates the worst case of having to check each regex in its entirety
params_without_match = {
  one: 'one',
  two: 'two',
  three: 'three',
  four: 'four',
  five: 'five',
  six: 'six',
  seven: 'seven',
  eight: 'eight',
  nine: 'nine',
  ten: 'ten'
}

benchmark_lambda = lambda do |x|
  x.report("original filters") do
    original.filter(params_without_match)
  end

  # Reduced filters provide a 20+% improvement in performance. Using a regex or not is in the margin of error.
  x.report("reduced filters with regex") do
    reduced_regex.filter(params_without_match)
  end

  x.report("reduced filters strings only") do
    reduced_strings.filter(params_without_match)
  end

  x.compare!
end

Benchmark.ips(&benchmark_lambda)
