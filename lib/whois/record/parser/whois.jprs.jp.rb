#--
# Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
# Copyright (c) 2009-2012 Simone Carletti <weppos@weppos.net>
#++


require 'whois/record/parser/base'


module Whois
  class Record
    class Parser

      # Parser for the whois.jprs.jp server.
      #
      # NOTE: This parser is just a stub and provides only a few basic methods
      # to check for domain availability and get domain status.
      # Please consider to contribute implementing missing methods.
      # See WhoisNicIt parser for an explanation of all available methods
      # and examples.
      #
      class WhoisJprsJp < Base

        property_supported :status do
          if content_for_scanner =~ /\[Status\]\s+(.+)\n/
            case $1.downcase
            when "active"
              :registered
            when "reserved"
              :reserved
            when "to be suspended"
              :redemption
            else
              Whois.bug!(ParserError, "Unknown status `#{$1}'.")
            end
          elsif content_for_scanner =~ /\[State\]\s+(.+)\n/
            case $1.split(" ").first.downcase
            when "connected"
              :registered
            else
              Whois.bug!(ParserError, "Unknown status `#{$1}'.")
            end
         else
            :available
          end
        end

        property_supported :available? do
          !!(content_for_scanner =~ /No match!!/)
        end

        property_supported :registered? do
          !available?
        end


        # TODO: timezone ('Asia/Tokyo')
        property_supported :created_on do
          if content_for_scanner =~ /\[(?:Created on|Registered Date)\][ \t]+(.*)\n/
            ($1.empty?) ? nil : Time.parse($1)
          end
        end

        # TODO: timezone ('Asia/Tokyo')
        property_supported :updated_on do
          if content_for_scanner =~ /\[Last Updated?\][ \t]+(.*)\n/
            ($1.empty?) ? nil : Time.parse($1)
          end
        end

        # TODO: timezone ('Asia/Tokyo')
        property_supported :expires_on do
          if content_for_scanner =~ /\[Expires on\][ \t]+(.*)\n/
            ($1.empty?) ? nil : Time.parse($1)
          end
        end


        property_supported :nameservers do
          content_for_scanner.scan(/\[Name Server\][\s\t]+([^\s\n]+?)\n/).flatten.map do |name|
            Record::Nameserver.new(name)
          end
        end

      end

    end
  end
end
