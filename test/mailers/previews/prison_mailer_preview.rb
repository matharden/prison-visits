class PrisonMailerPreview < ActionMailer::Preview
  include MailerPreviewCommon

  def booking_request
    PrisonMailer.booking_request_email(sample_visit, SecureRandom.hex * 40, 'localhost:3000')
  end

  def booking_receipt_accepted
    PrisonMailer.booking_receipt_email(sample_visit, accepted_confirmation)
  end

  def booking_receipt_rejected_no_slots
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation('no_slot_available'))
  end

  def booking_receipt_rejected_not_on_contact_list
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation('not_on_contact_list'))
  end
end
