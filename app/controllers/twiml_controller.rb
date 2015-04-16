class TwimlController < ApplicationController

  def verification_code
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Response {
        xml.Say('Hey this is zazo', voice: 'woman')
      }
    end

    render :xml => builder
  end

end