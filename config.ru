require 'app'
require 'lib/canonical_host'

use CanonicalHost do
  case ENV["RACK_ENV"].to_sym
    when :production then 'feed.ab-c.com.au'
  end
end

run Feed::Application