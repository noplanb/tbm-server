class TwimlController < ApplicationController

  def verification_code
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.response {
        xml.say "Hi this is zazo"
      }
    end

    render :xml => builder
  end

end