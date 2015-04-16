class TwimlController < ApplicationController

  def verification_code
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Response {
        xml.Say "Hi this is zazo"
      }
    end

    render :xml => builder
  end

end