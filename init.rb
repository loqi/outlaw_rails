# outlaw_rails 2.3 is optimized for use with rails 2.3.
# See README.txt for a discussion of how to get your Rails and Outlaw versions to match.

# Refuse to run on incompatible Rails versions.
rails_v_s = Rails::VERSION::STRING
rails_v_f = rails_v_s =~ /(\d+)(\.\d+)?/ ? $1.to_f + ($2 || 0).to_f : 0.0
unless rails_v_f >= 2.3 and rails_v_f < 2.5 # This uses a crystal ball to guess 2.4 is good but not 2.5.
  raise LoadError, "Outlaw Rails 2.3 plugin is not compatible with Rails version #{rails_v_s}.#{
    if    rails_v_f >  2.3 then " You'll need a newer Outlaw plugin, or older Rails."
    elsif rails_v_f <  2.3 then " You'll need an older Outlaw plugin, or newer Rails."
    elsif rails_v_f == 0.0 then " That version number format does not parse as number[.number...]" ; end
    } See the outlaw plugin's README.txt file for tips with synching versions."
  end

# Setting any of these to false will disable that portion:
extend_object      = true
extend_numeric     = true
extend_string      = true
extend_hash        = true
extend_comparable  = true
extend_ar_messages = true
extend_resources   = true

# If APP_CONFIG is a nested hash of the expected format, look for explicitly false settings.
# Ignore this code if APP_CONFIG is not present and in the expected format.
if defined?(APP_CONFIG) and opt = APP_CONFIG['outlaw_rails'] and opt.kind_of?(Hash)
  extend_object      &&= opt['extend_object'      ]
  extend_numeric     &&= opt['extend_numeric'     ]
  extend_string      &&= opt['extend_string'      ]
  extend_hash        &&= opt['extend_hash'        ]
  extend_hash        &&= opt['extend_comparable'  ]
  extend_ar_messages &&= opt['extend_ar_messages' ]
  extend_resources   &&= opt['extend_resources'   ]
  end

require 'object'      if extend_object
require 'numeric'     if extend_numeric
require 'string'      if extend_string
require 'hash'        if extend_hash
require 'comparable'  if extend_comparable
require 'ar_messages' if extend_ar_messages
require 'resources'   if extend_resources
