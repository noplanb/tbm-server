require 'spec_helper'

class TestClass < ActiveRecord::Base
  include SpecificCredential
end

describe SpecificCredential do

  pending "creates or returns singleton for instance" do

    # Kill all specific credentials
    SpecificCredential.all.each{|sc| sc.destroy}
    SpecificCredential.count.should == 0

    # Instance should return a new empty sc since none were in the db.
    sc = SpecificCredential.instance
    sc.cred_type.should == SpecificCredential::CRED_TYPE
    sc.cred.should_not be_nil

    SpecificCredential::ATTRIBUTES.each do |a|
      sc.send(a).should be_nil

      # Set all the attributes before saving
      setter = (a.to_s + "=").to_sym
      sc.send(setter, a.to_s)
    end

    sc.save
    # There should now be one in the db
    SpecificCredential.count.should == 1
    sc.cred.should_not be_nil

    # This should now return the one in the db
    sc = SpecificCredential.instance
    # It should have a json for cred
    sc.cred.should_not be_nil

    # Retrieving it should set all the attributes from the cred json.
    SpecificCredential::ATTRIBUTES.each do |a|
      sc.send(a).should == a.to_s
    end

  end

end
