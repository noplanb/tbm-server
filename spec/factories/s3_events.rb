FactoryGirl.define do
  factory :s3_event do
    bucket_name 'staging-videos.zazo.com'
    file_name   'ZcAK4dM9S4m0IFui6ok6-lpb8DcispONUSfdMOT9g-da6f35c931ea53de0e24fb4c76beb5f3'
  end

  factory :s3_event_legacy, class: S3Event do
    bucket_name 'staging-videos.zazo.com'
    file_name   'OoutNPPY7rCIVhlLsKKB-Z2TNnW0igOL0UzL457eQ-1c0f0cbdfd2a2ee8a8823db478c5a807'
  end
end
