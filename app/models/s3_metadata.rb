class S3Metadata
  attr_accessor :client_version

  class << self
    def create_by_event(s3_event)

    end

    private

    def fetch_metadata

    end
  end

  def initialize(attrs)
    self.client_version = attrs[:client_version]
  end
end
